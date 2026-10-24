ai_buffer=""
ai_result=""

get_ai_input() {
  buffer_pending=$(println "$ai_buffer" | wc -w | xargs)

  if [ "$buffer_pending" -eq 0 ]; then
    ai_buffer=$(bash $provider_file "$model" \
      "$system_prompt
      $chat_history" \
    )
  fi
}

read_ai_buffer() {
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

ai_loop() {
  get_ai_input
  read_ai_buffer

  local command=$(get_command "$ai_result")
  local content=$(get_content "$ai_result")
  local cmdtype=$(is_cmd_type "$command")

  if [ "$cmdtype" -eq 0 ]; then
    continue
  fi
  
  add_chat "assistant" "$ai_result"
  
  case "$command" in
    "/close")
      request_exit
      ;;
    "/pass")
      pass_control
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
}

