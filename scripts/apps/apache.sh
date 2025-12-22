#!/bin/bash
# Enable script termination in case of error
set -e
# ======================================================================================================================

install_apache(){
  command_exists apache2 || {
    fmt_trace "install apache2 ..."
    install_program apache2
  }

  # Enable the Apache SSL module
  run_cmd a2enmod ssl
  # Enable the Headers module
  run_cmd a2enmod headers
  # Restart the service to take into account the activation of the modules.
  run_cmd service apache2

  return 0
}

process_apache(){
  install_apache || return 1
  return 0
}