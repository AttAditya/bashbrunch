#!/bin/bash

brunch_root="."
session_id="$(date +%s)-$RANDOM-$RANDOM"

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

println() {
  printf "$@\n"
}

if [ "$version" != "$latest_version" ]; then
  println "A new version of BashBrunch is available: $latest_version"
  println "Please update your installation."
  println ""
fi

if [ "$1" = "--version" ] || [ "$1" = "-v" ]; then
  println "BashBrunch $version"
  exit 0
fi

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  cat $help_file
  exit 0
fi

resuming=0

if [ "$1" = "--session" ] || [ "$1" = "-s" ]; then
  resuming=1
fi

if [ "$1" = "--resume" ] || [ "$1" = "-r" ]; then
  resuming=1
fi

if [ "$resuming" -eq 1 ]; then
  if [ -z "$2" ]; then
    println "Please provide a session ID."
    exit 1
  fi

  session_id="$2"
  session_file="$data_dir/sessions/$session_id.txt"

  if [ ! -f "$session_file" ]; then
    println "Session ID $session_id does not exist."
    exit 1
  fi

  println "Resuming session $session_id"
fi

println "BashBrunch $version"
println "Use /? for help"
println ""

println "Session ID: $session_id"
println "Active Provider: $provider"
println "Active Model: $model"
println ""

history -c
history -r "$history_file"

if [ ! -f "$session_file" ]; then
  println "$system_prompt\n" > "$session_file"
fi

prompt=""
chat_history="$(cat "$session_file")"
ai_buffer=""
ai_result=""
requested_exit=0

add_chat() {
  chat_history="${chat_history}$1: $2\n"
  println "$1: $2" >> "$session_file"
}

run_shell() {
  println "\n[[ shell: $1 ]]"
  add_chat "shell" "$1"

  script_file=$(mktemp)
  output_file=$(mktemp)

  printf '%s\n' "$1" > "$script_file"
  bash "$script_file" > "$output_file" 2>&1
  exit_code=$?

  executed=$(cat "$output_file")
  rm -f "$script_file" "$output_file"
  
  println "$executed"
  add_chat "shell output" "$executed"
  println "[[ shell complete (code $exit_code) ]]\n"
  add_chat "shell" "execution complete (code $exit_code)"
}

use_ai() {
  buffer_pending=$(println "$ai_buffer" | wc -w | xargs)

  if [ "$buffer_pending" -eq 0 ]; then
    ai_buffer=$(bash $provider_file "$model" \
      "$system_prompt
      $chat_history" \
    )
  fi
}

read_buffer() {
  line_count=$(println "$ai_buffer" | wc -l | xargs)
  line_count=$((line_count))
  checkpoint=$(println "$ai_buffer\n/pass" \
    | tail -n +2 \
    | grep -n '^/' \
    | grep -o '^[^:]*' \
    | head -n 1
  )

  if [ -z "$checkpoint" ]; then
    checkpoint=$line_count
  fi

  ai_result=$(println "$ai_buffer" | head -n $checkpoint)
  ai_buffer=$(println "$ai_buffer" | tail -n +$((checkpoint + 1)))
}

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

run_ai() {
  while true; do
    use_ai
    read_buffer

    command=$(get_command "$ai_result")
    content=$(get_content "$ai_result")
    command_type=$(println "$command" \
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
        break
        ;;
      "/pass")
        break
        ;;
      "/msg")
        printf "$content"
        println "\n"
        ;;
      "/sh")
        run_shell "$content"
        ;;
      "/v")
        add_chat "system" $version
        println ""
        ;;
      *)
        add_chat "system" "Unknown command: $command"
        println "Unknown command: $command"
        println ""
        ;;
    esac
  done
}

while [ true ]; do
  if [ "$requested_exit" -eq 1 ]; then
    break
  fi

  empty=""
  read -ep ">$empty>$empty> " prompt
  history -s "$prompt"
  add_chat "user" "$prompt"
  command_type=$(println "$prompt" | grep '^\/' | wc -l | xargs)

  if [ "$prompt" = "" ]; then
    continue
  fi

  if [ "$command_type" -eq 0 ]; then
    run_ai
    continue
  fi

  command=$(println "$prompt" | grep -o '^[^ ]*')
  content=$(println "$prompt" | sed 's/^[^ ]* *//')
  skip_ai=0
  
  case "$command" in
    "/?")
      cat $help_file
      println ""
      skip_ai=1
      ;;
    "/v")
      println "BashBrunch $version"
      println ""
      skip_ai=1
      ;;
    "/p")
      if [ -z "$content" ]; then
        println "Active Provider: $provider"
      else
        println "$content" > "$provider_select_file"
        
        provider=$(cat $provider_select_file)
        provider_file="$brunch_root/providers/$provider.sh"
        model_select_file="$config_dir/models/$provider.txt"
        model=$(cat $model_select_file)
        
        println "Provider changed to $provider."
        println "Active Model: $model"
      fi

      println ""
      skip_ai=1
      ;;
    "/m")
      if [ -z "$content" ]; then
        println "Active Model: $model"
      else
        println "$content" > "$model_select_file"
        model=$(cat $model_select_file)
        println "Model changed to $model."
      fi
      
      println ""
      skip_ai=1
      ;;
    "/q")
      break
      ;;
    "/!")
      run_shell "$content"
      skip_ai=1
      ;;
    *)
      println "Unknown command: $command"
      skip_ai=1
      ;;
  esac

  if [ "$skip_ai" -eq 0 ]; then
    run_ai
  fi
done

if [ $requested_exit -eq 1 ]; then
  println "Exiting! (session closed by AI)"
else
  println "Exiting!"
fi

history -w "$history_file"
println "Session saved to $session_file"

