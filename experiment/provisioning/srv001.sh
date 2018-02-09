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
mariadb_root_password=letmein
mariadb_network_conf=/etc/my.cnf.d/network.cnf 
db_name=dbo
db_user=dbo
db_password=dbo

#------------------------------------------------------------------------------
# "Imports"
#------------------------------------------------------------------------------

# Utility functions
source ${PROVISIONING_SCRIPTS}/util.sh
# Actions/settings common to all servers
source ${PROVISIONING_SCRIPTS}/common.sh

#------------------------------------------------------------------------------
# Main function
#------------------------------------------------------------------------------

# The different steps in the installation/configuration process are split up
# in several functions.
main() {
  info "Starting server specific provisioning tasks on ${HOSTNAME}"
  install_packages

  configure_mariadb
  ensure_service_running mariadb.service
  secure_mariadb

  create_database
}

#------------------------------------------------------------------------------
# Helper functions
#------------------------------------------------------------------------------

install_packages() {
  info "Installing packages"

  yum install -y epel-release
  yum install -y \
    bash-completion \
    bash-completion-extras \
    git \
    mariadb-server \
    nano \
    psmisc \
    tree \
    vim-enhanced
  # You could optionally also install the package phpMyAdmin (case sensitive!)
}

# Installs MariaDB configuration file.
configure_mariadb() {
  if [ ! -f "${mariadb_network_conf}" ]; then
    info "MariaDB network configuration"
    cat > "${mariadb_network_conf}" << _EOF_
[mysqld]
bind-address = 0.0.0.0
_EOF_
  fi
}

secure_mariadb() {

  info "Securing database installation"
  info " - Set MariaDB root password to «${mariadb_root_password}»"

  if mysqladmin -u root status > /dev/null 2>&1; then
    # if the previous command succeeds, the root password was not set
    mysqladmin password "${mariadb_root_password}" > /dev/null 2>&1
    info "   -> ok"
  else
    info "   -> password already set."
  fi

  info " - Remove test database and anonymous user"

  mysql --user=root --password="${mariadb_root_password}" mysql << _EOF_
DELETE FROM user WHERE user='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
_EOF_

}

create_database() {

  info "Creating database «${db_name}» and user «${db_user}» with password «${db_password}»"

  if is_existing_database "${db_name}"; then
    info "Database already exists, skipping this step. To have this script recreate
    the database, drop it first by executing this command on the server:
    mysql -uroot -p${mariadb_root_password} <<< 'DROP DATABASE ${db_name}'"
  else
    mysql --user=root --password="${mariadb_root_password}" mysql << _EOF_
      CREATE DATABASE IF NOT EXISTS ${db_name};
      GRANT ALL ON ${db_name}.* TO '${db_user}'@'%' identified by '${db_password}';
      FLUSH PRIVILEGES;
_EOF_

    info "Creating tables in database ${db_name}"

    mysql --user="${db_user}" --password="${db_password}" "${db_name}" \
      < "${data_dir}/create-tables.sql"

    info "Loading data from CSV"

    for csv_file in "${data_dir}"/*.csv; do
      load_csv "${csv_file}"
    done

  fi
}

# Usage: load_csv FILE_PATH
#
# Will load the contents from the specified CSV into the database
# table with the same name as the file. The table should already exist and
# have the expected properties. The first line of the file is considered to
# be a column header and is skipped.
load_csv() {
  local -r csv_path="${1}"
  local -r csv_file="${csv_path##*/}"
  local -r table="${csv_file%%.*}"

  debug "loading file ${csv_path} -> ${table}"

  mysql --user=root --password="${mariadb_root_password}" "${db_name}" << _EOF_
  SET FOREIGN_KEY_CHECKS = 0;
  LOAD DATA INFILE '${csv_path}'
  REPLACE INTO TABLE ${table}
  FIELDS TERMINATED BY ';'
  IGNORE 1 LINES;
  SET FOREIGN_KEY_CHECKS = 1;
_EOF_
}

# Usage: is_existing_database DATABASE
#
# Predicate that checks if the specified DATABASE exists.
# Returns exit status 0 if it does, 1 if not.
is_existing_database () {
  [ -n "$(mysql -u"${db_user}" -p"${db_password}" 2> /dev/null <<< "SHOW DATABASES LIKE '${db_name}'")" ]
}

# Execute main function
main

