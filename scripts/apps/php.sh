#!/bin/bash
# Enable script termination in case of error
set -e
# ======================================================================================================================
add_repo(){
  command_exists apt-transport-https || {
    fmt_trace "install apt-transport-https ..."
    install_program apt-transport-https
  }
  command_exists lsb-release || {
    fmt_trace "install lsb-release ..."
    install_program lsb-release
  }
  command_exists ca-certificates || {
    fmt_trace "install ca-certificates ..."
    install_program ca-certificates
  }

  run_cmd wget -q --show-progress -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
  run_cmd sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
  update_system_silence
}

install_php(){
  run_cmd systemctl stop apache2
  run_cmd a2dismod mpm_prefork
  #---------------------------------------------------------------------------------------------------------------------
  command_exists "${PHPINST}" || {
    fmt_trace "install ${PHPINST} ..."
    install_program "${PHPINST}"
  }
  command_exists "${PHPINSTCLI}" || {
    fmt_trace "install ${PHPINSTCLI} ..."
    install_program "${PHPINSTCLI}"
  }

  install_program "${PHPINST}"-{curl,gd,intl,mysqli,bcmath,mbstring,zip,bz2,dom,simplexml,xmlreader,xmlwriter,ldap}
}

install_fpm(){
  #command_exists "${PHPINSTFPM}" || {
    fmt_trace "install ${PHPINSTFPM} ..."
    install_program "${PHPINSTFPM}"
  #}

  sleep 1

  run_cmd a2enmod proxy_fcgi setenvif
  run_cmd a2enmod rewrite deflate headers http2 mpm_event
  run_cmd a2enconf "${PHPINSTFPM}"
  run_cmd apachectl -k restart
  return 0
}

process_php(){
  add_repo
  install_php
  install_fpm || return 1
  return 0
}
