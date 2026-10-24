controllers=(
  "user"
  "ai"
)

controller=0
requested_exit=0

pass_control() {
  controller=$((controller + 1))
  controller=$((controller % ${#controllers[@]}))
}

get_controller() {
  echo "${controllers[$controller]}"
}

request_exit() {
  requested_exit=$((controller + 1))
}

