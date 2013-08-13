#!/bin/bash

verbose=false
limit=0

do_help() {
	echo "prints duplicate lines in a file"
	echo ""
	echo "usage:"
	echo "	$0 file [options]"
	echo ""
	echo "options:"
	echo "	--limit		Limits the number of characters used for comparison. Useful for cvs files where only the first column should be compared."
}

debug() {
	if [ $verbose == "true" ]; then
		echo "$1"
	fi
}

if [ "$1" == '--help' ]; then
	do_help
	exit 1
fi

file="$1"
if [ ! -f "$file" ]; then
	echo "first argument must be a file."
	exit 1
fi
shift

while test $# -gt 0
do
    case "$1" in
	    --help|-h)
    		do_help
    		exit 0
    	;;
    	--verbose|-v|--debug)
    		verbose=true
    	;;
        --limit)
        	shift
        	limit=$1
        	debug "limit set to $limit"
        ;;
        --*) echo "bad option '$1'"
        ;;
    esac
    shift
done

if [ $limit != 0 ]; then
	cat "$file" | sort | uniq --all-repeated=separate -w $limit
else
	cat "$file" | sort | uniq --all-repeated=separate
fi
