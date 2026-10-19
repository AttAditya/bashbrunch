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

response=$(echo "$response" | sed '
  s/\\u0026/\&/gi
  s/\\u0028/(/gi
  s/\\u0029/)/gi
  s/\\u002a/*/gi
  s/\\u002b/+/gi
  s/\\u003b/;/gi
  s/\\u003c/</gi
  s/\\u003d/=/gi
  s/\\u003e/>/gi
  s/\\u005b/[/gi
  s/\\u005c/\\/gi
  s/\\u005d/]/gi
  s/\\u005e/^/gi
  s/\\u0060/`/gi
  s/\\u007b/{/gi
  s/\\u007c/|/gi
  s/\\u007d/}/gi
  s/\\u007e/~/gi
')

printf '%b\n' "$response"

