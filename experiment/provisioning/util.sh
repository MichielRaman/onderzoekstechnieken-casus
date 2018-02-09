#! /usr/bin/bash
#
# Utility functions that are useful in all provisioning scripts.

#------------------------------------------------------------------------------
# Variables
#------------------------------------------------------------------------------

# Color definitions
readonly reset='\e[0m'
readonly cyan='\e[0;36m'
readonly red='\e[0;31m'
readonly yellow='\e[0;33m'

# Set to 'yes' if debug messages should be printed.
readonly debug_output='yes'

#------------------------------------------------------------------------------
# Logging and debug output
#------------------------------------------------------------------------------

# Three levels of logging are provided: info (for messages you always want to
# see), debug (for debug output that you only want to see if specified), and
# error (obviously, for error messages).

# Usage: info [ARG]...
#
# Prints all arguments on the standard output stream
info() {
  printf "${yellow}>>> %s${reset}\n" "${*}"
}

# Usage: debug [ARG]...
#
# Prints all arguments on the standard error stream
debug() {
  if [ "${debug_output}" = 'yes' ]; then
    printf "${cyan}### %s${reset}\n" "${*}" 1>&2
  fi
}

# Usage: error [ARG]...
#
# Prints all arguments on the standard error stream
error() {
  printf "${red}!!! %s${reset}\n" "${*}" 1>&2
}

#------------------------------------------------------------------------------
# Useful tests
#------------------------------------------------------------------------------

# Usage: files_differ FILE1 FILE2
#
# Tests whether the two specified files have different content
#
# Returns with exit status 0 if the files are different, a nonzero exit status
# if they are identical.
files_differ() {
  local file1="${1}"
  local file2="${2}"

  # If the second file doesn't exist, it's considered to be different
  if [ ! -f "${file2}" ]; then
    return 0
  fi

  local -r checksum1=$(md5sum "${file1}" | cut -c 1-32)
  local -r checksum2=$(md5sum "${file2}" | cut -c 1-32)

  [ "${checksum1}" != "${checksum2}" ]
}


#------------------------------------------------------------------------------
# SELinux
#------------------------------------------------------------------------------

# Usage: ensure_sebool VARIABLE
#
# Ensures that an SELinux boolean variable is turned on
ensure_sebool()  {
  local -r sebool_variable="${1}"
  local -r current_status=$(getsebool "${sebool_variable}")

  if [ "${current_status}" != "${sebool_variable} --> on" ]; then
    setsebool -P "${sebool_variable}" on
  fi
}

#------------------------------------------------------------------------------
# Service management
#------------------------------------------------------------------------------

# Usage: ensure_service_running SERVICE
#
# Ensures that the specified service is started and enabled (i.e. starts at
# boot time)
ensure_service_running() {
  local -r service="${1}"

  info "Ensuring ${service} is running and enabled at boot"

  if ! systemctl is-active "${service}"; then
    systemctl start "${service}"
  fi

  if ! systemctl is-enabled "${service}"; then
    systemctl enable "${service}"
  fi
}

#------------------------------------------------------------------------------
# User management
#------------------------------------------------------------------------------

# Usage: create_user USERNAME
#
# Create the user with the specified name if it doesn’t exist
ensure_user_exists() {
  local user="${1}"
  info "Ensure user ${user} exists"
  if ! getent passwd "${user}"; then
    info " -> user added"
    useradd "${user}"
  else
    info " -> already exists"
  fi
}

# Usage: ensure_group_exists GROUPNAME
#
# Creates the group with the specified name, if it doesn’t exist
ensure_group_exists() {
  local group="${1}"

  info "Ensure group ${group} exists"
  if ! getent group "${group}"; then
    info " -> group added"
    groupadd "${group}"
  else
    info " -> already exists"
  fi
}

# Usage: assign_groups USER GROUP...
#
# Adds the specified user to the specified groups
assign_groups() {
  local user="${1}"
  shift
  info "Adding user ${user} to groups: ${*}"
  while [ "$#" -ne "0" ]; do
    usermod -aG "${1}" "${user}"
    shift
  done
}
