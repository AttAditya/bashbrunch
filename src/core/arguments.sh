if [ "$1" = "--version" ] || [ "$1" = "-v" ]; then
  println "BashBrunch $version"
  exit 0
fi

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  cat $help_file
  exit 0
fi

resuming=0
for arg in --session -s --resume -r; do
  [[ "$1" == "$arg" ]] && resuming=1
done

if [ "$resuming" -eq 1 ]; then
  if [ -z "$2" ]; then
    println "Please provide a session ID."
    exit 1
  fi

  session_id="$2"
fi

incognito=0
colorfree=0

for arg in $@; do
  if [[ "$arg" == "--incognito" ]]; then
    incognito=1
    session_id="INCOGNITO"
  fi
  
  if [[ "$arg" == "--plain" ]]; then
    colorfree=1
  fi
done

