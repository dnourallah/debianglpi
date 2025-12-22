#!/bin/bash
# Enable script termination in case of error
set -e
# ======================================================================================================================

install_phpmyadmin(){
  command_exists phpmyadmin || {
    fmt_trace "install phpmyadmin ..."
    install_program phpmyadmin
  }
}

process_phpmyadmin(){
  install_phpmyadmin || return 1
  return 0
}