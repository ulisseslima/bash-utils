#!/bin/bash -e

verbose=false
debug=false

do_help() {
	echo "prints this message and exists"
	exit 0
}

while test $# -gt 0
do
    case "$1" in
		--verbose|-v) 
		    	verbose=true
		;;
		--debug|-d)
			debug=true
		;;
		--help|-h)
			do_help
		;;
		--*)
		    echo "invalid option: '$1'"
		    exit 1
		;;
    esac
    shift
done


