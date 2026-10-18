#!/bin/bash

brunch_root="."
session_id=$(echo "$(date +%s)-$RANDOM-$RANDOM")

if [ -n "$BRUNCH_ROOT" ]; then
  brunch_root="$BRUNCH_ROOT"
fi

version_file="$brunch_root/version.txt"

data_dir="$brunch_root/data"
config_dir="$brunch_root/config"

history_file="$data_dir/history.txt"
session_file="$data_dir/sessions/$session_id.txt"

help_file="$config_dir/help.txt"
system_file="$config_dir/system.txt"
provider_select_file="$config_dir/provider.txt"

system_prompt=$(cat $system_file)
provider=$(cat $provider_select_file)

provider_file="$brunch_root/providers/$provider.sh"
model_select_file="$config_dir/models/$provider.txt"
model=$(cat $model_select_file)

version=$(cat $version_file)

latest_version=$(curl \
  -s https://bashbrunch.attaditya.space/version.txt
)

echo() {
  printf "$@\n"
}

if [ "$version" != "$latest_version" ]; then
  echo "A new version of BashBrunch is available: $latest_version"
  echo "Please update your installation."
  echo ""
fi

echo "BashBrunch $version"
echo "Use /? for help"
echo ""

echo "Session ID: $session_id"
echo "Active Provider: $provider"
echo "Active Model: $model"
echo ""

history -c
history -r "$history_file"

prompt=""
chat_history="${system_prompt}\n"
ai_buffer=""
ai_result=""
requested_exit=0

add_chat() {
  chat_history="${chat_history}$1: $2\n"
}

run_shell() {
  echo "\n[[ shell: $1 ]]"
  add_chat "shell" "$1"

  script_file=$(mktemp)
  output_file=$(mktemp)

  printf '%s\n' "$1" > "$script_file"
  bash "$script_file" > "$output_file" 2>&1
  exit_code=$?

  executed=$(cat "$output_file")
  rm -f "$script_file" "$output_file"
  
  echo "$executed"
  add_chat "shell output" "$executed"
  echo "[[ shell complete (code $exit_code) ]]\n"
  add_chat "shell" "execution complete (code $exit_code)"
}

use_ai() {
  buffer_pending=$(echo "$ai_buffer" | wc -w | xargs)

  if [ "$buffer_pending" -eq 0 ]; then
    ai_buffer=$(bash $provider_file "$model" \
      "$system_prompt
      $chat_history" \
    )
  fi
}

read_buffer() {
  line_count=$(echo "$ai_buffer" | wc -l | xargs)
  line_count=$((line_count))
  checkpoint=$(echo "$ai_buffer\n/pass" \
    | tail -n +2 \
    | grep -n '^/' \
    | grep -o '^[^:]*' \
    | head -n 1
  )

  if [ -z "$checkpoint" ]; then
    checkpoint=$line_count
  fi

  ai_result=$(echo "$ai_buffer" | head -n $checkpoint)
  ai_buffer=$(echo "$ai_buffer" | tail -n +$((checkpoint + 1)))
}

get_command() {
  first_line=$(echo "$1" | head -n 1)
  command=$(echo "$first_line" | grep -o '^[^ ]*' | head -n 1)
  echo "$command"
}

get_content() {
  first_line=$(echo "$1" | head -n 1 | sed 's/^[^ ]* *//')
  rest_lines=$(echo "$1" | tail -n +2)
  echo "$first_line\n$rest_lines"
}

run_ai() {
  while true; do
    use_ai
    read_buffer

    command=$(get_command "$ai_result")
    content=$(get_content "$ai_result")
    command_type=$(echo "$command" \
      | grep '^\/' \
      | wc -l \
      | xargs \
    )

    if [ "$command_type" -eq 0 ]; then
      continue
    fi
    
    add_chat "assistant" "$ai_result"
    
    case "$command" in
      "/close")
        requested_exit=1
        ;;
      "/pass")
        break
        ;;
      "/msg")
        printf "$content"
        echo "\n"
        ;;
      "/sh")
        run_shell "$content"
        ;;
      "/v")
        add_chat "system" $version
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
  if [ "$requested_exit" -eq 1 ]; then
    break
  fi

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
      cat $help_file
      echo ""
      skip_ai=1
      ;;
    "/v")
      echo "BashBrunch $version"
      echo ""
      skip_ai=1
      ;;
    "/p")
      if [ -z "$content" ]; then
        echo "Active Provider: $provider"
      else
        echo "$content" > "$provider_select_file"
        
        provider=$(cat $provider_select_file)
        provider_file="$brunch_root/providers/$provider.sh"
        model_select_file="$config_dir/models/$provider.txt"
        model=$(cat $model_select_file)
        
        echo "Provider changed to $provider."
        echo "Active Model: $model"
      fi

      echo ""
      skip_ai=1
      ;;
    "/m")
      if [ -z "$content" ]; then
        echo "Active Model: $model"
      else
        echo "$content" > "$model_select_file"
        model=$(cat $model_select_file)
        echo "Model changed to $model."
      fi
      
      echo ""
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
echo "$chat_history" > "$session_file"
echo "Session saved to $session_file"

