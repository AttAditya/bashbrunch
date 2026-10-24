history -c
history -r "$history_file"

if [ ! -f "$session_file" ]; then
  println "$system_prompt\n" > "$session_file"
fi

chat_history="$(cat "$session_file")"

add_chat() {
  local entity="$1"
  local message="$2"
  local line="${entity}: ${message}"

  printf '%b\n' "${line}\n" >> "$session_file"
  chat_history="${chat_history}${line}\n"
}

post_session() {
  history -w "$history_file"
  println "Session saved to $session_file"
}

trap 'post_session' EXIT

