#!/bin/bash

dir="${1:-.}"
port="${2:-8666}"

server="$(which http-server)"
if [ ! -f "$server" ]; then
	echo "node http-server not installed. installing..."
	sudo npm install -g http-server
else
	echo "using '$server'"
fi

echo "serving '$dir'"

http-server "$dir" -p $port
