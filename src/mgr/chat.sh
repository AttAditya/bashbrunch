session_dir="$sessions_dir/$session_id"
session_file="$session_dir/chat.txt"

if [ ! -d "$session_dir" ]; then
  mkdir -p "$session_dir"
fi

history -c
history -r "$history_file"

if [ ! -f "$session_file" ]; then
  println "$system_prompt\n" > "$session_file"
  println "Session ID: $session_id" >> "$session_file"
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
  use_color_reset

  if [ "$incognito" -ne 0 ]; then
    rm -rf "$session_dir"
    return 0
  fi

  history -w "$history_file"
  println "\n\n(Session saved)"
  println "Resume with: brunch --resume $session_id"
}

trap 'post_session' EXIT

