run_shell() {
  println "\n[[ shell: $1 ]]"
  add_chat "shell" "$1"

  script_file=$(mktemp)
  output_file=$(mktemp)

  printf '%b\n' "$1" > "$script_file"
  bash "$script_file" > "$output_file" 2>&1
  exit_code=$?

  executed=$(cat "$output_file")
  rm -f "$script_file" "$output_file"
  
  println "$executed"
  add_chat "shell output" "$executed"
  println "[[ shell complete (code $exit_code) ]]\n"
  add_chat "shell" "execution complete (code $exit_code)"
}

