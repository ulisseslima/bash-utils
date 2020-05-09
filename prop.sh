#!/bin/bash
source $(real log.sh)

filename="$1"
thekey="$2"
newvalue="$3"

case "$1" in
    --verbose|-v) 
      debugging on
    ;;
    -*) 
      echo "bad option '$1'"
    ;;
esac

if [[ ! -n "$newvalue" ]]; then
  debug "GETTING '${thekey}'"
	sed -rn "s/^${thekey}=([^\n]+)$/\1/p" $filename
	exit 0
fi

if [ ! -f "$filename" ]; then
	mkdir -p "$(dirname $filename)"
    touch "$filename"
fi

if ! grep -R "^[#]*\s*${thekey}=.*" $filename > /dev/null; then
  debug "APPENDING '${thekey}'"
  echo "$thekey=${newvalue}" >> $filename
else
  debug "SETTING '${thekey}'"
  sed -ir "s/^[#]*\s*${thekey}=.*/$thekey=${newvalue}/" $filename
fi
