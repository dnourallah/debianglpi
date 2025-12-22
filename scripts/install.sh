#!/bin/bash
# Enable script termination in case of error
set -e
# ======================================================================================================================
source ./libs/messages.sh
source ./libs/lib.sh
source config.sh
# ======================================================================================================================
source ./apps/debian.sh
source ./apps/apache.sh
source ./apps/mariadb.sh
source ./apps/php.sh
source ./apps/phpmyadmin.sh
source ./apps/glpi.sh
# ======================================================================================================================
setup_color
# --- Parse arguments ---
if [[ "$#" -eq 0 ]]; then
  fmt_error "Unrecognized option."
  fmt_error "Try '$0 --help' for more information."
  #exit 1
else
while [[ "$#" -gt 0 ]]; do
  case "${1:-}" in
  -i|--install)
    installation='true'
    shift
    ;;
  -d|--unistall)
    desinstallation='true'
    shift
    ;;
  -h|--help)
    usage
    exit 0
    ;;
  *)
    fmt_error "Unrecognized option '$1'."
    fmt_error "Try '$0 --help' for more information."
    exit 1
    ;;
  esac
done
fi
# ======================================================================================================================
install() {
  echo
  fmt_info "Installing ..."

  process_debian || exit_error "Configuring system"

  process_apache || exit_error "Installing apache"

  process_php || exit_error "Installing php"

  process_mariadb || exit_error "Installing mariadb"

  process_phpmyadmin || exit_error "Installing phpmyadmin"

  process_glpi || exit_error "Installing glpi"

  sleep 2
  run_cmd service ssh restart
  run_cmd service ufw restart
  run_cmd service apache2 restart
}

uninstall() {
  fmt_info "Uninstall ... "
}
# ======================================================================================================================

if [[ "${installation:-'false'}" == 'true' ]]; then
  install_msq
  install
elif [[ "${desinstallation:-'false'}" == 'true' ]]; then
  uninstall_msq
  uninstall
else
  fmt_error "Unrecognized option."
fi

if [ $? -eq 0 ]; then
  done_msq
else
  error_msq
fi

