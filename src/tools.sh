get_shell_name() {
  local timestamp=$(date +%s)
  local random_string="$RANDOM-$RANDOM"
  echo "${timestamp}_${random_string}"
}

run_shell() {
  local shell_name=$(get_shell_name)
  local shells_dir="$session_dir/shells"

  if [ ! -d "$shells_dir" ]; then
    mkdir -p "$shells_dir"
  fi

  local script_file="${shells_dir}/${shell_name}.sh"
  local output_file="${shells_dir}/${shell_name}.out"
  local cmd_preview=$(printf "%b" "$1" \
    | head -n 1 \
    | head -c 50
  )

  if [ "$cmd_preview" != "$1" ]; then
    cmd_preview="${cmd_preview}..."
  fi

  println "\n[["
  println "  shell: ${script_file}"
  println "  command: ${cmd_preview}"
  println "]]"
  add_chat "shell" "$1"

  printf '%b\n' "$1" > "$script_file"
  bash "$script_file" > "$output_file" 2>&1

  exit_code=$?
  executed=$(cat "$output_file")

  println "${executed}"
  println "\n[["
  println "  shell complete"
  println "  output: ${output_file}"
  println "  exit code: ${exit_code}"
  println "]]\n"

  add_chat "shell output" "${executed}"
  add_chat "shell" "execution complete (code ${exit_code})"
}

