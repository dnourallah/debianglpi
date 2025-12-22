#!/bin/bash
# Enable script termination in case of error
set -e
# ======================================================================================================================

install_mariadb(){
  #---------------------------------------------------------------------------------------------------------------------
  command_exists mariadb-server || {
    fmt_trace "install mariadb-server ..."
    install_program mariadb-server
  }
  return 0
}

secure_mariadb(){
  #run_cmd mariadb_secure_installation
  fmt_info "secure_mariadb ..."
  return 0
}

process_mariadb(){
  install_mariadb || return 1
  secure_mariadb || return 1
  return 0
}