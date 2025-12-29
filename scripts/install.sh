#!/bin/bash
# Enable script termination in case of error
set -e
# ======================================================================================================================
CURR_DIR=$(cd "$(dirname "$0")" && pwd)
BASE_PATH=$(dirname "$(cd "$(dirname "$0")" && pwd)")
# ======================================================================================================================
source "$BASE_PATH/scripts/libs/messages.sh"
source "$BASE_PATH/scripts/libs/lib.sh"
#source "$BASE_PATH/scripts/configs/config.sh"
source "$BASE_PATH/scripts/configs/config_dev.sh"
# ======================================================================================================================
source "$BASE_PATH/scripts/apps/ssh.sh"
source "$BASE_PATH/scripts/apps/debian.sh"
source "$BASE_PATH/scripts/apps/apache.sh"
source "$BASE_PATH/scripts/apps/mariadb.sh"
source "$BASE_PATH/scripts/apps/php.sh"
source "$BASE_PATH/scripts/apps/phpmyadmin.sh"
source "$BASE_PATH/scripts/apps/glpi.sh"
# ======================================================================================================================
setup_color
# --- Parse arguments ---
if [[ "$#" -eq 0 ]]; then
  fmt_error "Unrecognized option."
  fmt_error "Try '$0 --help' for more information."
else
  while [[ "$#" -gt 0 ]]; do
    case "${1:-}" in
    -i|--install)
      is_install='true'
      shift
      ;;
    -d|--unistall)
      is_uninstall='true'
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
  etape "(1) => process debian"
  process_debian     || exit_error "Configuring system"
  process_apache     || exit_error "Installing apache"
  process_php        || exit_error "Installing php"
  process_mariadb    || exit_error "Installing mariadb"
  process_phpmyadmin || exit_error "Installing phpmyadmin"
  process_glpi       || exit_error "Installing glpi"
  configure          || exit_error "configure"
}

uninstall() {
  fmt_info "Uninstall ..."
}
# ======================================================================================================================
if [[ "${is_install:-'true'}" == 'true' ]]; then
  install_msq
  install
elif [[ "${is_uninstall:-'false'}" == 'true' ]]; then
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
