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

source "$brunch_root/src/utils.sh"
source "$brunch_root/src/tools.sh"
source "$brunch_root/src/mgr/chat.sh"
source "$brunch_root/src/mgr/control.sh"
source "$brunch_root/src/loop/ai.sh"
source "$brunch_root/src/loop/user.sh"

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
  println ""
fi

println "BashBrunch $version"
println "Use /? for help"
println ""

println "Session ID: $session_id"
println "Active Provider: $provider"
println "Active Model: $model"
println ""

while [ true ]; do
  if [ "$requested_exit" -ne 0 ]; then
    break
  fi

  active=$(get_controller)

  if [ "$active" = "user" ]; then
    user_loop
  elif [ "$active" = "ai" ]; then
    ai_loop
  fi
done

if [ $requested_exit -eq 1 ]; then
  println "Exiting! (session closed by AI)"
else
  println "Exiting!"
fi

