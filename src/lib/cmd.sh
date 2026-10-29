get_command() {
  first_line=$(println "$1" | head -n 1)
  command=$(println "$first_line" | grep -o '^[^ ]*' | head -n 1)
  println "$command"
}

get_content() {
  first_line=$(println "$1" | head -n 1 | sed 's/^[^ ]* *//')
  rest_lines=$(println "$1" | tail -n +2)
  println "$first_line\n$rest_lines"
}

is_cmd_type() {
  command=$(get_command "$1")
  valid=$(echo "$command" | grep -o '^/' | wc -w | xargs)

  if [ "$valid" -eq 0 ]; then
    echo 0
  else
    echo 1
  fi
}

