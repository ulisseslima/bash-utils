#!/bin/bash

dir="${1:-.}"
port="${2:-8666}"
cert="$3"

server="$(which http-server)"
if [ ! -f "$server" ]; then
	echo "node http-server not installed. installing..."
	sudo npm install -g http-server
else
	echo "using '$server'"
fi

echo "serving '$dir'"

# alternatively httpserv
if [[ -f "$cert" ]]; then
  http-server "$dir" -p $port -S -C "$cert"
else
  http-server "$dir" -p $port
fi
