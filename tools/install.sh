#!/bin/bash
# Enable script termination in case of error
set -e
# ======================================================================================================================
CURR_DIR=$(cd "$(dirname "$0")" && pwd)
BASE_PATH=$(dirname "$(cd "$(dirname "$0")" && pwd)")
# ======================================================================================================================
readonly ROOT_UID=0
# ======================================================================================================================
readonly MY_SCRIPT_INSTALL_VERSION="1.0 Beta"
# ======================================================================================================================

# Make sure important variables exist if not already defined
#
# $USER is defined by login(1) which is not always executed (e.g. containers)
# POSIX: https://pubs.opengroup.org/onlinepubs/009695299/utilities/id.html
USER=${USER:-$(id -u -n)}
USER_UID=${USER_UID:-$(id -u)}

TMP_DIR=${TMP_DIR:-/tmp/installglpi}
SCRIPT_DIR=${SCRIPT_DIR:-${TMP_DIR}/scripts}

# Default settings
REPO=${REPO:-dnourallah/debianglpi}
REMOTE=${REMOTE:-https://github.com/${REPO}.git}
BRANCH=${BRANCH:-main}

#  Check command availability
command_exists() {
  command -v "$@" 2>&1
}

setup_color() {
  FMT_RED=$(printf '\033[31m')
  FMT_GREEN=$(printf '\033[32m')
  FMT_YELLOW=$(printf '\033[33m')
  FMT_BLUE=$(printf '\033[34m')
  FMT_BOLD=$(printf '\033[1m')
  FMT_RESET=$(printf '\033[0m')
}

fmt_error() {
  printf '%sError: %s%s\n' "${FMT_BOLD}${FMT_RED}" "$*" "$FMT_RESET"
}

fmt_info() {
  printf '%sInfo: %s%s\n' "${FMT_BOLD}${FMT_BLUE}" "$*" "$FMT_RESET"
}

fmt_success() {
  printf '%sSuccess: %s%s\n' "${FMT_BOLD}${FMT_GREEN}" "$*" "$FMT_RESET"
}

fmt_trace() {
  printf '%sRun: %s%s\n' "${FMT_BOLD}${FMT_YELLOW}" "$*" "$FMT_RESET"
}

exit_error(){
  fmt_error "$*"
  exit 1
}

# Check if sudo is available
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
      sudo -k "$@"  # -k forces the password prompt
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

test_dependency(){
  # Check if sudo is installed
  command_exists sudo || apt install -qq -y sudo
  check_sudo
  command_exists git || install_program git
}

process_install(){
  echo

  test_dependency

  # Test pour vérifier si le dossier exist
  fmt_trace "checked folder ..."
  if [ -d "$TMP_DIR" ]; then
    fmt_info "delete ol folder"
    rm -rf "$TMP_DIR" || exit_error "delete failed"
  fi

  fmt_trace "create folder ..."
  mkdir -p "$TMP_DIR" || exit_error "create folder failed"

  # Manual clone with git config options to support git < v1.7.2
  fmt_trace "git clone ..."
  command_exists git || {
    fmt_error "git is not installed"
    exit 1
  }

  ostype=$(uname)
  if [ -z "${ostype%CYGWIN*}" ] && git --version | grep -Eq 'msysgit|windows'; then
    fmt_error "Windows/MSYS Git is not supported on Cygwin"
    fmt_error "Make sure the Cygwin git package is installed and is first on the \$PATH"
    exit 1
  fi

  # Prevent the cloned repository from having insecure permissions. Failing to do
  # so causes compinit() calls to fail with "command not found: compdef" errors
  # for users with insecure umasks (e.g., "002", allowing group writability). Note
  # that this will be ignored under Cygwin by default, as Windows ACLs take
  # precedence over umasks except for filesystems mounted with option "noacl".
  umask g-w,o-w

  fmt_trace "Cloning Debian GLPI..."

  git init --quiet "$TMP_DIR" && cd "$TMP_DIR" \
    && git config core.eol lf \
    && git config core.autocrlf false \
    && git config fsck.zeroPaddedFilemode ignore \
    && git config fetch.fsck.zeroPaddedFilemode ignore \
    && git config receive.fsck.zeroPaddedFilemode ignore \
    && git config debianglpi.remote origin \
    && git config debianglpi.branch "$BRANCH" \
    && git remote add origin "$REMOTE" \
    && git fetch --quiet --depth=1 origin \
    && git checkout --quiet -b "$BRANCH" "origin/$BRANCH" || {
    [ ! -d "$TMP_DIR" ] || {
      cd -
      fmt_info "delete ol folder !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
      rm -rf "$TMP_DIR" 2>/dev/null
    }
    exit_error "git clone of debianglpi repo failed"
  }

  echo
  fmt_trace "script GLPI ..."
  cd "$SCRIPT_DIR" || exit_error "E000001"
  pwd

  run_cmd chmod +x install.sh
  run_cmd bash ./install.sh -i || exit_error "install failed"
}

question(){
  echo
  printf '%s#=================================================================#%s\n' "${FMT_BOLD}${FMT_BLUE}" "$FMT_RESET" >&2
  printf '%s#==================         Nouri PN v%s        ============#%s\n' "${FMT_BOLD}${FMT_BLUE}" "$MY_SCRIPT_INSTALL_VERSION" "$FMT_RESET" >&2
  printf '%s#=================================================================#%s\n' "${FMT_BOLD}${FMT_BLUE}" "$FMT_RESET" >&2
  echo
  # Prompt for user choice on changing the default login shell
  printf '%sDo you want to install GLPI server ? [Y/n]%s ' "$FMT_YELLOW" "$FMT_RESET"
  while true; do
    read -r answer
    case $answer in
    [Yy]*|"")
      process_install
      break
      ;;
    [Nn]*)
      fmt_error "installation aborted ..."
      exit 1
      ;;
    *) fmt_error "Invalid choice.Answer either yes or no!";;
    esac
  done
}

setup_color
question
