#!/bin/bash

# reads from std in or first arg. the catch is that it hangs if none are provided
#stdin="${1:-`cat /proc/${$}/fd/0`}"
file="$1"
if [ ! -f "$file" ]; then
	echo "o primeiro argumento deve ser um arquivo com os arquivos a serem criados"
	exit 1
fi
shift

MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
verbose=false
extension=TXT

do_help() {
	echo "Usage:"
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
	--ext|-x)
		shift
		extension=$1
		debug "extension is $extension"
	;;
        --*) echo "bad option $1"
        	exit 1
	    ;;
    esac
    shift
done

while read line
do
	echo "$line" | grep -qE "\....$" # line ends with a dot and three characters?
	if [[ $? == 0 ]]; then
		debug "creating file $line"
		touch "$line"
	else
		mkdir -p "$line"
	fi
done < "$file"

