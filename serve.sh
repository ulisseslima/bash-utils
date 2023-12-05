#!/bin/bash
# https://www.npmjs.com/package/http-server
dir="${1:-.}"
port="${2:-8666}"
cert="$3"

server="$(which http-server)"
if [ ! -f "$server" ]; then
	echo "node http-server not installed. installing..."
	npm install -g http-server
else
	echo "using '$server'"
fi

echo "serving '$dir'"

# alternatively httpserv
if [[ -f "$cert" ]]; then
  http-server "$dir" -p $port -S -C "$cert" --cors
else
  http-server "$dir" -p $port --cors
fi
