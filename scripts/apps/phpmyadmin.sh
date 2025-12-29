#!/bin/bash
# Enable script termination in case of error
set -e
# ======================================================================================================================
update_config(){
  local dir="$1"

  run_cmd cp "$dir/${PHPMYADMIN_CONFIG_SAMPLE_FILE}" "$dir/${PHPMYADMIN_CONFIG_FILE}"
  # https://dwaves.de/tools/escape/
  run_cmd sed -i "s/\$cfg\[\x27blowfish_secret\x27\] = \x27\x27;/\$cfg\[\x27blowfish_secret\x27\] = \x27${PHPMYADMIN_SECRET}\x27;/g"  "$dir/${PHPMYADMIN_CONFIG_FILE}"

  run_cmd bash -c "cat << EOF >> $dir/${PHPMYADMIN_CONFIG_FILE}

_REPLACE_DOLLAR_cfg['Servers'][_REPLACE_DOLLAR_i]['hide_db'] = '^(sys|mysql|information_schema|performance_schema)$';
EOF"

  run_cmd sed -i "s/_REPLACE_DOLLAR_/$/g"  "$dir/${PHPMYADMIN_CONFIG_FILE}"
  return 0
}

install_phpmyadmin(){
  local name="phpmyadmin.local"
  local dirname_name="${APACHE_SITE_PATH}/$name"
  local dirname_extracted="/tmp/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages/"

  fmt_trace "install phpmyadmin ..."

  [[ -d "${dirname_name}" ]] || run_cmd mkdir -p "${dirname_name}"

  create_apache_virtualhost "$name" "$dirname_name" "${PHPMYADMIN_APACHE_CONFIG_FILE}"

  wget -q --show-progress -O /tmp/phpMyAdmin.tar.gz -P /tmp "${PHPMYADMIN_URL}"
  tar -xzf /tmp/phpMyAdmin.tar.gz -C /tmp
  sleep 2
  run_cmd mv -f "$dirname_extracted"* "$dirname_name"
  sleep 2

  [[ ! -d "$dirname_extracted" ]] || run_cmd rm -rf "$dirname_extracted"
  [[ -e /tmp/phpMyAdmin.tar.gz ]] && run_cmd rm -f /tmp/phpMyAdmin.tar.gz
  run_cmd chown -R www-data:www-data "$dirname_name"
  run_cmd chmod -R 755 "$dirname_name"

  update_config "$dirname_name" || return 1
  return 0
}

active_phpmyadmin(){
  run_cmd a2ensite "${PHPMYADMIN_APACHE_CONFIG_NAME}" || return 1
  run_cmd apachectl -k restart
  return 0
}

process_phpmyadmin(){
  install_phpmyadmin || return 1
  active_phpmyadmin || return 1
  return 0
}
