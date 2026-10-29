ai_buffer=""
ai_result=""

get_ai_input() {
  buffer_pending=$(println "$ai_buffer" | wc -w | xargs)

  if [ "$buffer_pending" -eq 0 ]; then
    ai_buffer=$(bash $provider_file \
      "$api_key" \
      "$model" \
      "$chat_history"
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
    "/v")
      add_chat "system" $version
      println ""
      ;;
    "/sh")
      run_shell "$content"
      ;;
    "/msg")
      printf "$content"
      println "\n"
      ;;
    "/sh2a")
      ssf_append "$content"
      println "[[ SSF Appended ]]"
      ;;
    "/sh2r")
      ssf_read "$content"
      println "[[ SSF Read ]]"
      ;;
    "/sh2x")
      ssf_execute "$content"
      ;;
    "/sh2c")
      ssf_clear
      println "[[ SSF Cleared ]]"
      ;;
    "/pass")
      pass_control
      ;;
    "/exit")
      request_exit
      ;;
    *)
      add_chat "system" "Unknown command: $command"
      println "Unknown command: $command"
      println ""
      ;;
  esac
}

