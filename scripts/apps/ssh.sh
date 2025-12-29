#!/bin/bash
# Enable script termination in case of error
set -e
# ======================================================================================================================

fix_ssh() {
  #run_cmd sed -i -e "s/^[#]*Port[[:space:]].*$/Port ${SSH_PORT}/g" "${SSH_CONFIG_FILE}"
  #run_cmd sed -i -e 's/^[#]*PermitRootLogin[[:space:]].*$/PermitRootLogin no/g' "${SSH_CONFIG_FILE}"

  run_cmd bash -c "cat << EOF >> ${SSH_CONFIG_PERSO_FILE}
# ssh
Port ${SSH_PORT}
Protocol 2
PermitRootLogin yes
PasswordAuthentication yes
#PermitRootLogin no
#PasswordAuthentication no
#PubkeyAuthentication yes
PubkeyAuthentication yes
ChallengeResponseAuthentication no
AllowAgentForwarding no
PermitTunnel no
X11Forwarding no
MaxAuthTries 3
UsePAM yes
ClientAliveInterval 0
ClientAliveCountMax 2
LoginGraceTime 300
Ciphers aes256-gcm@openssh.com,chacha20-poly1305@openssh.com
KexAlgorithms curve25519-sha256,diffie-hellman-group-exchange-sha256
MACs hmac-sha2-512-etm@openssh.com,umac-128-etm@openssh.com
LogLevel VERBOSE
EOF" || return 1
}

install_ssh(){
  command_exists ssh || {
    fmt_trace "install ssh ..."
    install_program ssh
  }

  if command_exists ssh; then
    return 0
  fi
}

process_ssh(){
  install_ssh || return 1
  return 0
}
