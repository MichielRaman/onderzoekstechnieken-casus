#! /usr/bin/bash
#
# Provisioning script for srv001

#------------------------------------------------------------------------------
# Bash settings
#------------------------------------------------------------------------------

# abort on nonzero exitstatus
set -o errexit
# abort on unbound variable
set -o nounset
# don't mask errors in piped commands
set -o pipefail

#------------------------------------------------------------------------------
# Variables
#------------------------------------------------------------------------------

# Location of provisioning scripts and files
export readonly PROVISIONING_SCRIPTS="/vagrant/provisioning/"
# Location of files to be copied to this server
export readonly PROVISIONING_FILES="${PROVISIONING_SCRIPTS}/${HOSTNAME}"

# Location of data to be imported (= table creation script and CSV files)
data_dir=/vagrant/data

# Database name, user, password
db_name=dbo

#------------------------------------------------------------------------------
# "Imports"
#------------------------------------------------------------------------------

# Utility functions
source ${PROVISIONING_SCRIPTS}/util.sh
# Actions/settings common to all servers
source ${PROVISIONING_SCRIPTS}/common.sh

#------------------------------------------------------------------------------
# MariaDB/MySQL stuff
#------------------------------------------------------------------------------

# Usage: load_csv FILE_PATH
#
# Will load the contents from the specified CSV into the database
# table with the same name
load_csv() {
  local -r csv_path="${1}"
  local -r csv_file="${csv_path##*/}"
  local -r table="${csv_file%%.*}"

  debug "loading file ${csv_path} -> ${table}"

  mysql --user=root "${db_name}" << _EOF_
  SET FOREIGN_KEY_CHECKS = 0;
  LOAD DATA INFILE '${csv_path}'
  REPLACE INTO TABLE ${table}
  FIELDS TERMINATED BY ';'
  IGNORE 1 LINES;
  SET FOREIGN_KEY_CHECKS = 1;
_EOF_
}

#------------------------------------------------------------------------------
# Provision server
#------------------------------------------------------------------------------

info "Starting server specific provisioning tasks on ${HOSTNAME}"

info "Installing packages"

yum install -y epel-release
yum install -y mariadb-server \
  nano vim-enhanced

info "Configuring MariaDB"

ensure_service_running mariadb.service

info "Creating database & user"
info "db name: ${db_name}"
mysql --user=root < "${data_dir}/create-db.sql"

info "Loading data from CSV"

for csv_file in "${data_dir}"/*.csv; do
  load_csv "${csv_file}"
done

