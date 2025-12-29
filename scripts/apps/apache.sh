#!/bin/bash
# Enable script termination in case of error
set -e
# ======================================================================================================================

install_apache(){
  command_exists apache2 || {
    fmt_trace "install apache2 ..."
    install_program apache2
  }

  sleep 1

  if command_exists apache2; then
    # Enable the Apache SSL module
    run_cmd a2enmod ssl
    run_cmd apachectl -k restart
    return 0
  else
    return 1
  fi
}

process_apache(){
  install_apache || return 1
  return 0
}
