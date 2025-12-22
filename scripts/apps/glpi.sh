#!/bin/bash
# Enable script termination in case of error
set -e
# ======================================================================================================================

install_glpi(){
  local name="glpi.local"
  local dirname_name="${APACHE_SITE_PATH}/$name"
  local dirname_full="$dirname_name/public"

  echo
  fmt_info "Installing GLPI v${GLPI_VERSION} in '$dirname_name'..."

  [[ -d "${dirname_full}" ]] || run_cmd mkdir -p "${dirname_full}"

  create_apache_virtualhost "$name" "$dirname_full"

  wget -q --show-progress -O /tmp/glpi.tgz -P /tmp "${GLPI_URL}"
  tar -xzf /tmp/glpi.tgz -C /tmp
  sleep 2
  run_cmd mv -f /tmp/glpi/* "$dirname_name"
  sleep 2
  [[ ! -d /tmp/glpi ]] || run_cmd rm -rf /tmp/glpi
  [[ -e /tmp/glpi.tgz ]] && run_cmd rm -f /tmp/glpi.tgz
  run_cmd chown -R www-data:www-data "$dirname_name"
  run_cmd chmod -R 755 "$dirname_name"
}

active_glpi(){
  run_cmd a2ensite "${GLPI_APACHE_CONFIG_NAME}" || return 1
  sleep 2
  run_cmd service apache2 restart
  sleep 5
  return 0
}

process_glpi(){
  install_glpi || return 1
  active_glpi || return 1
  return 0
}
