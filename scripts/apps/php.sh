#!/bin/bash
# Activer l'arrêt du script en cas d'erreur
set -e
# ======================================================================================================================
phpR=php"${PHP_VERSION}"

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
  #---------------------------------------------------------------------------------------------------------------------
  command_exists "$phpR" || {
    fmt_trace "install ${PHP_VERSION} ..."
    install_program "$phpR"
  }
  command_exists "$phpR"-cli|| {
    fmt_trace "install $phpR-cli ..."
    install_program "$phpR"-cli
  }

  install_program "$phpR"-{curl,gd,intl,mysqli,bcmath,mbstring,zip,bz2,dom,simplexml,xmlreader,xmlwriter,ldap}
}

fix_fpm(){
  command_exists "$phpR"-fpm || {
    fmt_trace "install $phpR-fpm ..."
    install_program "$phpR"-fpm
  }

  run_cmd a2enmod proxy_fcgi setenvif
  run_cmd a2enconf "$phpR"-fpm
  run_cmd a2enmod rewrite deflate
  run_cmd systemctl restart apache2 || return 1
  return 0
}

process_php(){
  add_repo
  install_php
  fix_fpm || return 1
  return 0
}
