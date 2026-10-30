api_key=$1
model=$2
prompt=$3

response=$(curl -fsS https://ollama.com/api/generate \
  -H "Authorization: Bearer $api_key" \
  -H "Content-Type: application/json" \
  -d "$(jq -n \
    --arg model "$model" \
    --arg prompt "$prompt" \
    '{model: $model, prompt: $prompt, stream: false}')"
)

error=$(jq -r '.error' <<< "$response")

if ! [ $error = "null" ]; then
  error_message=$(jq -r '.error' <<< "$response")

  echo "/msg Ollama error: $error_message"
  echo "/pass"

  exit 0
fi

response=$(jq -r '.response' <<< "$response")

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

