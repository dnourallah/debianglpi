#!/bin/bash
# Enable script termination in case of error
set -e
# ======================================================================================================================
readonly ROOT_UID=0
# ======================================================================================================================
# Make sure important variables exist if not already defined
#
# $USER is defined by login(1) which is not always executed (e.g. containers)
# POSIX: https://pubs.opengroup.org/onlinepubs/009695299/utilities/id.html
USER=${USER:-$(id -u -n)}
USER_UID=${USER_UID:-$(id -u)}

#  Check command availability
command_exists() {
  command -v "$@" 2>&1
}

# Vérifier si sudo est disponible
check_sudo() {
  command_exists sudo || exit_error "sudo is not installed. You must install it to continue."
}

user_is_root(){
  # En shell :
  #return 0 = vrai / succès
  #return 1 (ou autre ≠0) = faux / échec

  if [ "$USER_UID" -eq "$ROOT_UID" ]; then
    return 0   # root → vrai
  else
    return 1   # non-root → faux
  fi
}

user_can_sudo() {
  # Check if sudo is installed
  command_exists sudo || return 1
  # Termux can't run sudo, so we can detect it and exit the function early.
  case "$PREFIX" in
  *com.termux*) return 1 ;;
  esac
  # The following command has 3 parts:
  #
  # 1. Run `sudo` with `-v`. Does the following:
  #    • with privilege: asks for a password immediately.
  #    • without privilege: exits with error code 1 and prints the message:
  #      Sorry, user <username> may not run sudo on <hostname>
  #
  # 2. Pass `-n` to `sudo` to tell it to not ask for a password. If the
  #    password is not required, the command will finish with exit code 0.
  #    If one is required, sudo will exit with error code 1 and print the
  #    message:
  #    sudo: a password is required
  #
  # 3. Check for the words "may not run sudo" in the output to really tell
  #    whether the user has privileges or not. For that we have to make sure
  #    to run `sudo` in the default locale (with `LANG=`) so that the message
  #    stays consistent regardless of the user's locale.
  #
  ! LANG= sudo -n -v 2>&1 | grep -q "may not run sudo"
}

run_cmd(){
  if user_is_root; then
    if user_can_sudo; then
      sudo -k "$@" # -k forces the password prompt
    else
      "$@"          # run normally
    fi
  else
    fmt_error "This script must be executed with sudo !"
  fi
}

install_program(){
  if command_exists zypper; then
    run_cmd zypper in -y "$@"
  elif command_exists swupd; then
    run_cmd swupd bundle-add "$@"
  elif command_exists apt; then
    run_cmd apt install -qq -y "$@"
  elif command_exists apt-get; then
    run_cmd apt-get install -qq -y "$@"
  elif command_exists dnf; then
    run_cmd dnf install -y "$@"
  elif command_exists yum; then
    run_cmd yum install -y "$@"
  elif command_exists pacman; then
    run_cmd pacman -Syyu --noconfirm --needed "$@"
  elif command_exists xbps-install; then
    run_cmd xbps-install -Sy "$@"
  elif command_exists eopkg; then
    run_cmd eopkg -y install "$@"
  else
    exit_error "No supported package manager found."
  fi
}

update_system_silence(){
  run_cmd apt update -qq && run_cmd apt upgrade -qq -y
  echo
}
# ======================================================================================================================
install_msq() {
  echo
  printf '%s#=======================================================================================================================#%s\n' "${FMT_BOLD_BLUE}" "$FMT_RESET"
  printf '%s#    Install Debian server and GLPI                                                                                     #%s\n' "${FMT_BOLD_BLUE}" "$FMT_RESET"
  printf '%s#    Nouri version %s                                                                                             #%s\n' "${FMT_BOLD_BLUE}" "$MY_SCRIPT_VERSION" "$FMT_RESET"
  printf '%s#=======================================================================================================================#%s\n' "${FMT_BOLD_BLUE}" "$FMT_RESET"
}

uninstall_msq() {
  echo
  printf '%s#=======================================================================================================================#%s\n' "${FMT_BOLD}${FMT_GREEN}" "$FMT_RESET"
  printf '%s#    Uninstall Debian server and GLPI                                                                                     #%s\n' "${FMT_BOLD}${FMT_GREEN}" "$FMT_RESET"
  printf '%s#    Nouri version %s                                                                                     #%s\n' "${FMT_BOLD}${FMT_GREEN}" "$MY_SCRIPT_VERSION" "$FMT_RESET"
  printf '%s#=======================================================================================================================#%s\n' "${FMT_BOLD}${FMT_GREEN}" "$FMT_RESET"
}

done_msq() {
  clear
  install_msq
  echo
  if [[ ${INSTALL_OPTIONAL} == "true" ]]; then
    fmt_success "Installation wget curl ssh vim git htop ufw"
  fi
  fmt_success "Installation apache2"
  fmt_success "Installation php v${PHP_VERSION}"
  fmt_success "Installation mariadb"
  fmt_success "Installation phpmyadmin v${PHPMYADMIN_VERSION}"
  fmt_success "Installation GLPI v${GLPI_VERSION}"
  echo

  printf '%s#=======================================================================================================================#%s\n' "${FMT_BOLD_BLUE}" "$FMT_RESET"
  printf '%s#    done Enjoy !                                                                                                       #%s\n' "${FMT_BOLD_BLUE}" "$FMT_RESET"
  printf '%s#=======================================================================================================================#%s\n' "${FMT_BOLD_BLUE}" "$FMT_RESET"
}

error_msq() {
  clear
  install_msq
  echo
  printf '%s#=======================================================================================================================#%s\n' "${FMT_BOLD_RED}" "$FMT_RESET"
  printf '%s#    Error                                                                                                              #%s\n' "${FMT_BOLD_RED}" "$FMT_RESET"
  printf '%s#=======================================================================================================================#%s\n' "${FMT_BOLD_RED}" "$FMT_RESET"
}
# ======================================================================================================================
generate_certificat(){
  local name="$1"
  local cert="$2"
  local cert_key="$3"

  [[ -d "/etc/ssl/apache2" ]] || run_cmd mkdir -p "/etc/ssl/apache2"

  run_cmd openssl req -x509 -nodes -days 365 -newkey rsa:2048 -sha256 \
    -out "$cert" \
    -keyout "$cert_key" \
    -subj "/C=FR/ST=state/L=city/O=organisation/OU=departement/CN=$name"
}

create_apache_virtualhost(){
  local name="$1"
  local dest="$2"
  local config="$3"

  local cert="/etc/ssl/apache2/cert_$name.pem"
  local cert_key="/etc/ssl/apache2/cert_$name.key"
  local log='\${APACHE_LOG_DIR}/'${name}'_error.log'
  local log_access='\${APACHE_LOG_DIR}/'${name}'_access.log'
  local log_ssl='\${APACHE_LOG_DIR}/'${name}'_ssl_error.log'
  local log_access_ssl='\${APACHE_LOG_DIR}/'${name}'_ssl_access.log'

  generate_certificat "*.$name" "$cert" "$cert_key"

  run_cmd bash -c "cat << EOF > $config
<VirtualHost *:80>
    ServerAdmin webmaster@$name
    ServerName www.$name
    ServerAlias $name
    DocumentRoot $dest

    <Directory $dest>
      Options -Indexes +FollowSymLinks
      Require all granted
      RewriteEngine On
    </Directory>

    ErrorLog $log
    CustomLog $log_access combined
</VirtualHost>

<IfModule mod_ssl.c>
<VirtualHost *:443>
    ServerAdmin webmaster@$name
    ServerName www.$name
    ServerAlias $name
    DocumentRoot $dest

    #   SSL Engine Switch:
    #   Enable/Disable SSL for this virtual host.
    SSLEngine on

    #   SSLCertificateFile directive is needed.
    SSLCertificateFile      $cert
    SSLCertificateKeyFile   $cert_key

    ErrorLog $log_ssl
    CustomLog $log_access_ssl combined
</VirtualHost>
</IfModule>
EOF"
}
