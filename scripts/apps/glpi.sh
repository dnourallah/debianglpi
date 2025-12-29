#!/bin/bash
# Enable script termination in case of error
set -e
# ======================================================================================================================

create_htaccess(){
  local dir="$1"

  run_cmd bash -c "cat << EOF >> $dir/.htaccess
RewriteBase /

# Ensure authorization headers are passed to PHP.
# Some Apache configurations may filter them and break usage of API, CalDAV, ...
RewriteCond %{HTTP:Authorization} ^(.+)$
RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]

# Redirect all requests to GLPI router, unless file exists.
RewriteCond %{REQUEST_FILENAME} !-f
RewriteRule ^(.*)$ index.php [QSA,L]
EOF"
}

install_glpi(){
  local name="glpi.local"
  local dirname_name="${APACHE_SITE_PATH}/$name"
  local dirname_full="$dirname_name/public"

  echo
  fmt_info "Installing GLPI v${GLPI_VERSION} in '$dirname_name'..."

  [[ -d "${dirname_full}" ]] || run_cmd mkdir -p "${dirname_full}"

  create_apache_virtualhost "$name" "$dirname_full" "${GLPI_APACHE_CONFIG_FILE}"

  wget -q --show-progress -O /tmp/glpi.tgz -P /tmp "${GLPI_URL}"
  tar -xzf /tmp/glpi.tgz -C /tmp
  sleep 2
  run_cmd mv -f /tmp/glpi/* "$dirname_name"
  sleep 1

  create_htaccess "${dirname_full}"
  run_cmd chown -R www-data:www-data "$dirname_name"
  run_cmd chmod -R 755 "$dirname_name"

  [[ ! -d /tmp/glpi ]] || run_cmd rm -rf /tmp/glpi
  [[ -e /tmp/glpi.tgz ]] && run_cmd rm -f /tmp/glpi.tgz

  return 0
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
