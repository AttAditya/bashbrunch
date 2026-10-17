#!/bin/bash

brunch_root="."

history_file="$brunch_root/history.txt"
system_prompt=$(cat $brunch_root/system.txt)
provider=$(cat $brunch_root/provider.txt)
provider_file="$brunch_root/providers/$provider.sh"
model=$(cat $brunch_root/models/$provider.txt)
session_id=$(uuidgen)

echo "BashBrunch $(cat $brunch_root/version.txt)"
echo "Use /? for help"
echo ""

history -c
history -r "$history_file"

prompt=""
chat_history="${system_prompt}\n"
ai_buffer=""

add_chat() {
  chat_history="${chat_history}$1: $2\n"
}

run_shell() {
  echo "\n[[ shell: $1 ]]"
  add_chat "shell" "$1"
  executed=$(eval "$1")
  echo "$executed"
  add_chat "shell output" "$executed"
  echo "[[ shell complete ]]\n"
  add_chat "shell" "execution complete"
}

use_ai() {
  buffer_pending=$(echo "$ai_buffer" | wc -w | xargs)

  if [ "$buffer_pending" -eq 0 ]; then
    ai_buffer=$(sh $provider_file "$model" \
      "$system_prompt
      $chat_history" \
    )
  fi
}

run_ai() {
  while true; do
    use_ai
    
    result=$(echo "$ai_buffer" | head -n 1)
    ai_buffer=$(echo "$ai_buffer" | tail -n +2)

    add_chat "assistant" "$result"
    
    command_type=$(echo "$result" \
      | grep '^\/' \
      | wc -l \
      | xargs \
    )
    
    if [ "$command_type" -eq 0 ]; then
      continue
    fi

    command=$(echo "$result" | grep -o '^[^ ]*' | head -n 1)
    content=$(echo "$result" | sed 's/^[^ ]* *//')
    
    case "$command" in
      "/pass")
        break
        ;;
      "/msg")
        echo "$content"
        echo ""
        ;;
      "/sh")
        run_shell "$content"
        ;;
      "/v")
        add_chat "system" $(cat $brunch_root/version.txt)
        echo ""
        ;;
      *)
        add_chat "system" "Unknown command: $command"
        echo "Unknown command: $command"
        echo ""
        ;;
    esac
  done
}

while [ true ]; do
  read -ep ">>> " prompt
  history -s "$prompt"
  add_chat "user" "$prompt"
  command_type=$(echo "$prompt" | grep '^\/' | wc -l | xargs)

  if [ "$prompt" = "" ]; then
    continue
  fi

  if [ "$command_type" -eq 0 ]; then
    run_ai
    continue
  fi

  command=$(echo "$prompt" | grep -o '^[^ ]*')
  content=$(echo "$prompt" | sed 's/^[^ ]* *//')
  skip_ai=0
  
  case "$command" in
    "/?")
      cat $brunch_root/help.txt
      echo ""
      skip_ai=1
      ;;
    "/v")
      cat $brunch_root/version.txt
      echo ""
      skip_ai=1
      ;;
    "/p")
      if [ -z "$content" ]; then
        echo "Please provide a provider name."
      else
        echo "$content" > "$brunch_root/provider.txt"
        provider=$(cat $brunch_root/provider.txt)
        provider_file="$brunch_root/providers/$provider.sh"
        echo "Provider changed to $provider."
      fi
      skip_ai=1
      ;;
    "/m")
      if [ -z "$content" ]; then
        echo "Please provide a model name."
      else
        echo "$content" > "$brunch_root/models/$provider.txt"
        model=$(cat $brunch_root/models/$provider.txt)
        echo "Model changed to $model."
      fi
      skip_ai=1
      ;;
    "/q")
      echo "Exiting..."
      break
      ;;
    "/!")
      run_shell "$content"
      skip_ai=1
      ;;
    *)
      echo "Unknown command: $command"
      skip_ai=1
      ;;
  esac

  if [ "$skip_ai" -eq 0 ]; then
    run_ai
  fi
done

history -w "$history_file"
echo "$chat_history" > "$brunch_root/sessions/$session_id.txt"
echo "Session saved to $brunch_root/sessions/$session_id.txt"

