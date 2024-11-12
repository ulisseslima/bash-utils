#!/bin/bash
# https://dashboard.ngrok.com/get-started/setup/linux
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

port=8080
mode=http

while test $# -gt 0
do
    case "$1" in
        --verbose|-v|--debug) 
        	verbose=true
        ;;
        --port|-p)
			shift
        	shift=$1
        ;;
		--https|-s)
			mode=https
        ;;
        -*) echo "bad option $1"
        	exit 1
	    ;;
    esac
    shift
done

ngrok $mode "http://localhost:$port"
