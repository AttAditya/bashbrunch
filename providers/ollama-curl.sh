#!/bin/bash

ollama_check=$(curl -s http://localhost:11434 | grep -o "Ollama is running" | wc -l | xargs)

if [ "$ollama_check" -eq 0 ]; then
  echo "/msg Ollama server is not running."
  echo "/pass"

  exit 0
fi

model=$1
prompt=$2
prompt=${prompt//\\/\\\\}
prompt=${prompt//\"/\\\"}
prompt=${prompt//$'\n'/\\n}
prompt=${prompt//$'\r'/\\r}
prompt=${prompt//$'\t'/\\t}

response=$(curl -s -X POST "http://localhost:11434/api/generate" \
  -H "Content-Type: application/json" \
  -d "{\"prompt\": \"$prompt\", \"model\": \"$model\", \"stream\": false}"
)

response=$(grep -o '"response": *"[^"]*"' <<< "$response" \
  | sed 's/"response": *"\(.*\)"/\1/')

printf '%b\n' "$response"

