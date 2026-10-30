println() {
  printf '%b\n' "$@"
}

get_temp_name() {
  local timestamp=$(date +%s)
  local random_string="$RANDOM-$RANDOM"
  echo "${timestamp}_${random_string}"
}

