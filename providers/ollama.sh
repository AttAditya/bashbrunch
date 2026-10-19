response=$(ollama run "$@" --hidethinking | cat)
contents=""

while IFS= read -r line; do
  ending=$(echo $line \
    | cat -v \
    | grep -o "\^\[\[[0-9]*D\^\[\[K$"
  )

  flagged=$(echo $ending \
    | wc -w \
    | xargs
  )

  if [ "$flagged" -eq 0 ]; then
    line=$(echo "$line" \
      | sed 's/\ *$//' \
      | sed 's/^\ *//'
    )
    
    contents="${contents}${line}\n"
    continue
  fi

  line=$(echo "$line" \
    | cat -v \
    | sed 's/\ [^\ ]*\^\[\[[0-9]*D\^\[\[K$//'
  )
  
  contents="${contents}${line} "
done <<< "$response"

printf '%b\n' "$contents"
printf '\n'

