#!/bin/bash
# Enable script termination in case of error
set -e
# ======================================================================================================================

INSTALL_OPTIONAL="false"

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
    install_program wget curl ssh vim git htop ufw
  else
    fmt_info "optional ignored  ..."
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

fix_user_group() {
  if getent group sudo | grep -qw "${YOUR_USERNAME}"; then
    fmt_info "user group ok"
  else
    run_cmd usermod -aG sudo "${YOUR_USERNAME}"
  fi
}

fix_ssh() {
  run_cmd sed -i -e 's/^#*Port 22/Port 22/g' "${SSH_CONFIG_FILE}"

  run_cmd sed -i -e 's/^#*PermitRootLogin none/PermitRootLogin yes/g' "${SSH_CONFIG_FILE}"

  run_cmd sed -i -e 's/^#*PermitRootLogin prohibit-password/PermitRootLogin yes/g' "${SSH_CONFIG_FILE}"

  run_cmd systemctl restart ssh
}

configure(){
  if [[ ${INSTALL_OPTIONAL} == "true" ]]; then
    #-----------------------------------------
    fix_ssh
    #-----------------------------------------
    #run_cmd  sed -i -e 's/ZSH_THEME="robbyrussell"/ZSH_THEME="jonathan"/g' /root/.zshrc
    #-----------------------------------------
    run_cmd ufw allow ssh
    run_cmd ufw allow 'WWW Full'
    run_cmd ufw enable
    run_cmd ufw reload
    run_cmd service ufw restart
  fi
}

process_debian(){
  update_system
  install_optional
  fix_ip
  fix_user_group
  return 0
}