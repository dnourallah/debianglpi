#!/bin/bash
# Enable script termination in case of error
set -e
# ======================================================================================================================

install_mariadb(){
  #---------------------------------------------------------------------------------------------------------------------
  command_exists mariadb-server || {
    fmt_trace "install mariadb-server ..."
    install_program mariadb-server
    run_cmd systemctl enable --now mariadb
  }
  return 0
}

secure_mariadb(){
  if command_exists mariadb-secure-installation; then
    fmt_info "secure_mariadb ..."
    run_cmd mariadb-secure-installation
    run_cmd systemctl restart mariadb
  fi
  return 0
}

process_mariadb(){
  install_mariadb || return 1
  return 0
}
