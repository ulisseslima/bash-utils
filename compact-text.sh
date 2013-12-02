#!/bin/bash

MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
verbose=false
extension='.log'
location=''
output='logs.grepd'
grep_expr='at org.'
remove_original=false

do_help() {
	echo "Reduces log size by removing lines that match the expression of all files in a directory, with the provided extension. Not recursive."
	echo "default values are:"
	echo "expression: 'at org'"
	echo "output file name: logs.grepd"
	echo "extension: .log"
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
        --extension)
        	shift
        	extension=$1
        ;;
        --dir|-d)
        	shift
        	location="$1"
        ;;
        --out|-o)
        	shift
        	output="$1"
        ;;
        --expr|-e)
        	shift
        	grep_expr="$1"
        ;;
        --remove-original|-r)
        	remove_original=true
        ;;
        --*) echo "bad option $1"
        	exit 1
	    ;;
    esac
    shift
done

if [ ! -d "$location" ]; then
	echo "directory not found: $location"
	exit 1
else
	echo "using '$location'"
fi

for f in "$location/"*$extension
do
	echo "compacting '$f'..."
	file="$(readlink -f "$f")"
	file_dir="${file%/*}"
	grep "$grep_expr" "$f" >> "$file_dir/$output"
	if [ "$remove_original" == true ]; then
		rm "$f"
	fi
done

exit 0
