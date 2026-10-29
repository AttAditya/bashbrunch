BG_RESET=$'\033[49m'
TX_RESET=$'\033[39m'
BG_USER=$'\033[48;5;240m'
TX_USER=$'\033[38;5;250m'
BG_AI=$'\033[48;5;236m'
TX_AI=$'\033[38;5;255m'
BG_TOOL=$'\033[48;5;24m'
TX_TOOL=$'\033[38;5;117m'
BG_SHELL=$'\033[48;5;22m'
TX_SHELL=$'\033[38;5;120m'

use_color_user() {
  printf '%s' "${BG_USER}${TX_USER}"
}

use_color_ai() {
  printf '%s' "${BG_AI}${TX_AI}"
}

use_color_tool() {
  printf '%s' "${BG_TOOL}${TX_TOOL}"
}

use_color_shell() {
  printf '%s' "${BG_SHELL}${TX_SHELL}"
}

use_color_reset() {
  printf '%s' "${BG_RESET}${TX_RESET}"
}

