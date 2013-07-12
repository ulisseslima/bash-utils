#!/bin/bash -e

verbose=false

do_help() {
	echo "shows the last x uses of a command in .bash_history"
	echo ""
	echo "usage:"
	echo "$0 5 ssh"
	echo "shows the last 5 occurrences of ssh in .bash_history"
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

cat ~/.bash_history | grep "$2" | tail -$1

exit 0
