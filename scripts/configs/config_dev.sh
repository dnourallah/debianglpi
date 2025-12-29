#!/bin/bash
# Enable script termination in case of error
set -e
# ======================================================================================================================
readonly MY_SCRIPT_VERSION="1.1 Beta"
# ======================================================================================================================
readonly YOUR_USERNAME="stagiaire"
readonly ADMIN_USERNAME="adminserver"
readonly ADMIN_PASSWORD="Mot_de_passe_server@admin"
readonly YOUR_IP="192.168.11.130"
readonly YOUR_IP_MASQUE="255.255.255.0"
readonly SSH_PORT=22
# ======================================================================================================================
readonly APACHE_CONFIG_PATH="/etc/apache2/sites-available"
readonly APACHE_SITE_PATH="/var/www"
readonly NETWORK_CONFIG_FILE="/etc/network/interfaces"
readonly SSH_CONFIG_FILE="/etc/ssh/sshd_config"
readonly SSH_CONFIG_PERSO_FILE="/etc/ssh/sshd_config.d/my_sshd_config.conf"
# ======================================================================================================================
readonly PHP_VERSION="8.2"
readonly PHPINST="php${PHP_VERSION}"
readonly PHPINSTCLI="php${PHP_VERSION}-cli"
readonly PHPINSTFPM="php${PHP_VERSION}-fpm"
# ======================================================================================================================
readonly PHPMYADMIN_VERSION="5.2.3"
readonly PHPMYADMIN_URL="https://files.phpmyadmin.net/phpMyAdmin/${PHPMYADMIN_VERSION}/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.gz"
readonly PHPMYADMIN_APACHE_CONFIG_NAME="001-phpmyadmin.conf"
readonly PHPMYADMIN_APACHE_CONFIG_FILE="${APACHE_CONFIG_PATH}/${PHPMYADMIN_APACHE_CONFIG_NAME}"
readonly PHPMYADMIN_CONFIG_SAMPLE_FILE="config.sample.inc.php"
readonly PHPMYADMIN_CONFIG_FILE="config.inc.php"
readonly PHPMYADMIN_SECRET="nH66lyo7E:uFOq8{E2@86[<Rba];-Q]h"

# ======================================================================================================================
readonly GLPI_VERSION="11.0.4"
readonly GLPI_URL="https://github.com/glpi-project/glpi/releases/download/${GLPI_VERSION}/glpi-${GLPI_VERSION}.tgz"
readonly GLPI_APACHE_CONFIG_NAME="002-glpi.conf"
readonly GLPI_APACHE_CONFIG_FILE="${APACHE_CONFIG_PATH}/${GLPI_APACHE_CONFIG_NAME}"
# ======================================================================================================================

usage() {
  cat << EOF
Usage: $0 [OPTION] ...

OPTIONS:
  -i                       Install
  -u                       uninstall
  -h                       Show this help
EOF
}
