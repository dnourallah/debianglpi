#!/bin/bash
# Enable script termination in case of error
set -e
# ======================================================================================================================
readonly YOUR_USERNAME="stagiaire"
readonly YOUR_IP="192.168.11.130"
readonly YOUR_IP_MASQUE="255.255.255.0"
# ======================================================================================================================
readonly APACHE_CONFIG_PATH="/etc/apache2/sites-available"
readonly APACHE_SITE_PATH="/var/www"
readonly NETWORK_CONFIG_FILE="/etc/network/interfaces"
readonly SSH_CONFIG_FILE="/etc/ssh/sshd_config"
# ======================================================================================================================
readonly PHP_VERSION="8.2"
readonly GLPI_VERSION="11.0.4"
readonly GLPI_URL="https://github.com/glpi-project/glpi/releases/download/${GLPI_VERSION}/glpi-${GLPI_VERSION}.tgz"
readonly GLPI_APACHE_CONFIG_NAME="001-glpi.conf"
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
