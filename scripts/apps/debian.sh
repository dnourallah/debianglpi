#!/bin/bash
# Enable script termination in case of error
set -e
# ======================================================================================================================
# Update debian
update_system(){
  if question_ask "Do you want to update system"; then
    fmt_info "Updating system ..."
    update_system_silence
  else
    fmt_info "Updating system ignored ..."
  fi
}

install_optional(){
  if question_ask "Do you want to install optional packages"; then
    fmt_info "Installing optional ..."
    INSTALL_OPTIONAL="true"
    install_program wget curl ssh vim git htop ufw openssl
  else
    fmt_info "optional ignored ..."
  fi
}

fix_ip(){
  run_cmd grep -i -E "iface ens33 inet static" "${NETWORK_CONFIG_FILE}" || {
    run_cmd bash -c "cat << EOF >> ${NETWORK_CONFIG_FILE}

# The internal network interface
allow-hotplug ens33
iface ens33 inet static
	address ${YOUR_IP}
	netmask ${YOUR_IP_MASQUE}

EOF"
    run_cmd systemctl restart networking
  }
}

add_admin_user(){
  # Créer un nouvel utilisateur
  run_cmd useradd "${ADMIN_USERNAME}" -p "${ADMIN_PASSWORD}"
}

fix_user_group() {
  # Ajouter l'utilisateur au groupe sudo pour les privilèges administratifs
  if getent group sudo | grep -qw "${ADMIN_USERNAME}"; then
    fmt_info "user group ok"
  else
    run_cmd usermod -aG sudo "${ADMIN_USERNAME}"
  fi
}

configure(){
  if command_exists apache2; then
    fmt_trace "configuring apache2 ..."
    run_cmd systemctl restart "${PHPINSTFPM}".service
    run_cmd apachectl -k start
    run_cmd apachectl -k restart
  fi

  if [[ ${INSTALL_OPTIONAL} == "true" ]]; then

    if command_exists ufw; then
      fmt_trace "configuring ufw ..."
      run_cmd ufw allow ssh
      run_cmd ufw allow 'WWW Full'
      run_cmd ufw enable
      run_cmd ufw reload
      run_cmd service ufw restart
      sleep 1
    fi

    if command_exists ssh; then
      fmt_trace "configuring ssh ..."
      fix_ssh || return 1
      run_cmd service ssh restart
    fi

  fi

  if command_exists mariadb; then
    fmt_trace "configuring mariadb ..."
    secure_mariadb || return 1
  fi
}

process_debian(){
  update_system
  install_optional
  fix_ip
  add_admin_user
  fix_user_group
  process_ssh
  return 0
}
