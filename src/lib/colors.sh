COLOR_FOCUS='231;159;61' # rgb(231, 159, 61);
COLOR_PRIME='255;231;165' # rgb(255, 231, 165);
COLOR_HYPED='255;232;201' # rgb(255, 232, 201);
COLOR_SHADE='92;64;51' # rgb(92, 64, 51);
COLOR_SHINE='255;248;231' # rgb(255, 248, 231);
COLOR_WHITE='255;255;255' # rgb(255, 255, 255);
COLOR_BLACK='0;0;0' # rgb(0, 0, 0);

BG_USER=$'\033[48;2;'${COLOR_SHINE}m
BG_AI=$'\033[48;2;'${COLOR_WHITE}m
BG_TOOL=$'\033[48;2;'${COLOR_FOCUS}m
BG_SHELL=$'\033[48;2;'${COLOR_BLACK}m

TX_USER=$'\033[38;2;'${COLOR_BLACK}m
TX_AI=$'\033[38;2;'${COLOR_BLACK}m
TX_TOOL=$'\033[38;2;'${COLOR_SHINE}m
TX_SHELL=$'\033[38;2;'${COLOR_WHITE}m

BG_RESET=$'\033[49m'
TX_RESET=$'\033[39m'

use_color_reset() {
  if [ "$colorfree" -ne 0 ]; then
    return 0
  fi

  printf "${BG_RESET}${TX_RESET}"
}

use_color_user() {
  if [ "$colorfree" -ne 0 ]; then
    return 0
  fi

  printf "${BG_USER}${TX_USER}\n"
}

use_color_ai() {
  if [ "$colorfree" -ne 0 ]; then
    return 0
  fi

  printf "${BG_AI}${TX_AI}"
}

use_color_tool() {
  if [ "$colorfree" -ne 0 ]; then
    return 0
  fi

  printf "${BG_TOOL}${TX_TOOL}"
}

use_color_shell() {
  if [ "$colorfree" -ne 0 ]; then
    return 0
  fi

  printf "${BG_SHELL}${TX_SHELL}\n"
}

