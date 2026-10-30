ssf_dir="$session_dir/ssf"
ssf_file="$session_dir/ssf.sh"

ssf_prepare() {
  if [ ! -d "$ssf_dir" ]; then
    mkdir -p "$ssf_dir"
  fi

  if [ ! -f "$ssf_file" ]; then
    touch "$ssf_file"
  fi
}

ssf_read() {
  ssf_prepare

  local start=$(echo "$1" \
    | grep -o "^[^ ]*" \
    | grep -o "[0-9]*"
  )

  local count=$(echo "$1" \
    | grep -o "^[^ ]*\ [^ ]*" \
    | grep -o "[^ ]*$" \
    | grep -o "[0-9]*"
  )

  if [ -z "$start" ]; then
    start=1
  fi

  if [ -z "$count" ]; then
    count=20
  fi

  ssf_content=$(cat "$ssf_file" \
    | head -n $((start + count - 1)) \
    | tail -n $count
  )

  add_chat "ssf" "\n${ssf_content}\n"
}

ssf_clear() {
  ssf_prepare
  printf '' > "$ssf_file"
}

ssf_append() {
  ssf_prepare
  echo "$1" >> "$ssf_file"
}

ssf_execute() {
  ssf_prepare

  local persist=$1

  if [ -z "$persist" ]; then
    persist=0
  else
    persist=1
  fi

  local ssf_content=$(cat "$ssf_file")
  local shell_name=$(get_temp_name)
  
  local script_file="${ssf_dir}/${shell_name}.sh"
  local output_file="${ssf_dir}/${shell_name}.out"
  
  local cmd_preview=$(printf "%b" "${ssf_content}" \
    | head -n 1 \
    | head -c 50
  )

  if [ "$cmd_preview" != "${ssf_content}" ]; then
    cmd_preview="${cmd_preview}..."
  fi

  println "\n[["
  println "  shell: ${script_file}"
  println "  command: ${cmd_preview}"
  println "]]"
  add_chat "shell" "${ssf_content}"

  printf '%b\n' "${ssf_content}" > "$script_file"
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

  if [ $persist -eq 0 ]; then
    ssf_clear
  fi
}

