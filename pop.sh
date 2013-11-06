#!/bin/bash

MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
verbose=false
file="$1"
shift
if [ ! -f "$file" ]; then
	echo "first argument must be an existing file"
	exit 1
fi

do_help() {
	echo "Usage:"
	echo "$0 file.txt"
	echo "will print the last line, and remove it from the file"
}

debug() {
	if [ $verbose == "true" ]; then
		echo "$1"
	fi
}

while test $# -gt 0
do
    case "$1" in
        --verbose|-v|--debug) 
        	verbose=true
        ;;
        --help|-h)
        	do_help
        	exit 0
        ;;
        --*) echo "bad option $1"
        	exit 1
	    ;;
    esac
    shift
done

sed -e $(wc -l <"$file")$'{w/dev/stdout\n;d}' -i "$file"

exit 0
