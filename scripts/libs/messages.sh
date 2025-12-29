#!/bin/bash
# Enable script termination in case of error
set -e

setup_color() {
  # Reset
  FMT_RESET=$(printf '\033[0m')
  # BOLD
  FMT_BOLD=$(printf '\033[1m')
  # Underline
  FMT_UNDERLINE=$(printf '\033[4m')
  # Flash/blink
  FMT_FLASH=$(printf '\033[5m')
  # Negative
  FMT_NEGATIVE=$(printf '\033[7m')

  # Regular Colors
  FMT_BLACK=$(printf '\033[0;30m')      # Black
  FMT_RED=$(printf '\033[31m')          # Red
  FMT_GREEN=$(printf '\033[32m')        # Green
  FMT_YELLOW=$(printf '\033[33m')       # Yellow
  FMT_BLUE=$(printf '\033[34m')         # Blue
  FMT_PURPLE=$(printf '\033[0;35m')     # Purple
  FMT_CYAN=$(printf '\033[0;36m')       # Cyan
  FMT_WHITE=$(printf '\033[0;37m')      # White

  # Bold
  FMT_BOLD_BLACK="${FMT_BOLD}${FMT_BLACK}"     # Bold Black
  FMT_BOLD_RED="${FMT_BOLD}${FMT_RED}"         # Bold Red
  FMT_BOLD_GREEN="${FMT_BOLD}${FMT_GREEN}"     # Bold Green
  FMT_BOLD_YELLOW="${FMT_BOLD}${FMT_YELLOW}"   # Bold Yellow
  FMT_BOLD_BLUE="${FMT_BOLD}${FMT_BLUE}"       # Bold Blue
  FMT_BOLD_PURPLE="${FMT_BOLD}${FMT_PURPLE}"   # Bold Purple
  FMT_BOLD_CYAN="${FMT_BOLD}${FMT_CYAN}"       # Bold Cyan
  FMT_BOLD_WHITE="${FMT_BOLD}${FMT_WHITE}"     # Bold White

  # Underline
  FMT_UNDERLINE_BLACK="${FMT_UNDERLINE}${FMT_BLACK}"     # Underline Black
  FMT_UNDERLINE_RED="${FMT_UNDERLINE}${FMT_RED}"         # Underline Red
  FMT_UNDERLINE_GREEN="${FMT_UNDERLINE}${FMT_GREEN}"     # Underline Green
  FMT_UNDERLINE_YELLOW="${FMT_UNDERLINE}${FMT_YELLOW}"   # Underline Yellow
  FMT_UNDERLINE_BLUE="${FMT_UNDERLINE}${FMT_BLUE}"       # Underline Blue
  FMT_UNDERLINE_PURPLE="${FMT_UNDERLINE}${FMT_PURPLE}"   # Underline Purple
  FMT_UNDERLINE_CYAN="${FMT_UNDERLINE}${FMT_CYAN}"       # Underline Cyan
  FMT_UNDERLINE_WHITE="${FMT_UNDERLINE}${FMT_WHITE}"     # Underline White
}

fmt_error() {
  printf '%sError: %s%s\n' "${FMT_BOLD_RED}" "$*" "$FMT_RESET"
}

fmt_info() {
  printf '%sInfo: %s%s\n' "${FMT_BOLD_BLUE}" "$*" "$FMT_RESET"
}

fmt_success() {
  printf '%sSuccess: %s%s\n' "${FMT_BOLD_GREEN}" "$*" "$FMT_RESET"
}

fmt_trace() {
  printf '%sRun: %s%s\n' "${FMT_BOLD_CYAN}" "$*" "$FMT_RESET"
}

fmt_warn() {
  printf '%sRun: %s%s\n' "${FMT_BOLD_PURPLE}" "$*" "$FMT_RESET"
}

exit_error(){
  fmt_error "$*"
  exit 1
}

etape(){
  echo
  echo
  printf '%s#=========================================================================#%s\n' "${FMT_BOLD_BLUE}"      "$FMT_RESET"
  printf '%s#    Setup : %s %s\n'                                                            "${FMT_BOLD_BLUE}" "$*" "$FMT_RESET"
  printf '%s#=========================================================================#%s\n' "${FMT_BOLD_BLUE}"      "$FMT_RESET"
}


# ======================================================================================================================
question_ask(){
  # En shell :
  #return 0 = vrai / succès
  #return 1 (ou autre ≠0) = faux / échec
  echo
  # Prompt for user choice on changing the default login shell
  printf '%s%s ? [Y/n]%s ' "$FMT_BOLD_YELLOW" "$*" "$FMT_RESET"
  while true; do
    read -r answer
    case $answer in
    [Yy]*|"")
      return 0
      ;;
    [Nn]*)
      return 1
      ;;
    *) fmt_error "Invalid choice.Answer either yes or no!";;
    esac
  done
}
