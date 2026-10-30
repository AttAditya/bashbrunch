user_buffer=""
user_result=""

get_user_input() {
  local empty=""
  read -ep ">$empty>$empty> " prompt
  history -s "$prompt"
  user_buffer="$prompt"
}

read_user_buffer() {
  user_result="$user_buffer"
  user_buffer=""
}

user_loop() {
  get_user_input
  read_user_buffer
  add_chat "user" "$user_result"

  if [ "$user_result" = "" ]; then
    continue
  fi

  command=$(get_command "$user_result")
  content=$(get_content "$user_result")
  cmdtype=$(is_cmd_type "$command")

  if [ "$cmdtype" -eq 0 ]; then
    pass_control
    continue
  fi
  
  case "$command" in
    "/?")
      cat $help_file
      println ""
      ;;
    "/v")
      println "BashBrunch $version"
      println ""
      ;;
    "/p")
      if [ -z "$content" ]; then
        println "Active Provider: $provider"
      else
        println "$content" > "$provider_select_file"
        
        provider=$(cat $provider_select_file)
        provider_file="$brunch_root/providers/$provider.sh"
        
        api_key_file="$data_dir/keys/$provider.txt"
        api_key=$(cat $api_key_file)

        model_select_file="$data_dir/models/$provider.txt"
        model=$(cat $model_select_file)
        
        println "Provider changed to $provider."
        println "Active Model: $model"
      fi

      println ""
      ;;
    "/k")
      if [ -z "$content" ]; then
        if [ -z "$api_key" ]; then
          println "No API Key set for $provider."
        else
          println "API Key exists for $provider."
        fi
      else
        println "$content" > "$api_key_file"
        api_key=$(cat $api_key_file)
        println "API Key changed."
      fi
      
      println ""
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
      ;;
    "/q")
      request_exit
      ;;
    "/!")
      run_shell "$content"
      ;;
    *)
      cmdtype=$(is_cmd_type "$command")
      if [ "$valid" -ne 0 ]; then
        println "Unknown command: $command"
      fi
      ;;
  esac
}

