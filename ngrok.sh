#!/bin/bash
# https://dashboard.ngrok.com/get-started/setup/linux
# # /home/ulisses/.config/ngrok/ngrok.yml
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
verbose=false

do_help() {
	echo "Usage:"
	echo "$0"
	echo "will expose local server on http 8080"
}

debug() {
	if [[ $verbose == "true" ]]; then
		echo "$1"
	fi
}

# local app port
port=8080

# exposed address mode
mode=http

while test $# -gt 0
do
    case "$1" in
        --verbose|-v|--debug)
        	verbose=true
        ;;
	--http|-k)
		mode=http
        ;;
	--https|-s)
		mode=https
        ;;
        --port|-p)
		shift
        	port=$1
        ;;
        -*) echo "bad option $1"
        	exit 1
	;;
    esac
    shift
done

ngrok $mode "http://localhost:$port"
