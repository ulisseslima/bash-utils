#!/bin/bash
# list local dependencies of a Java source file

MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"

source $(real require.sh)

sourcef="$1"
require -f sourcef
shift

# find module directory from source file. this is the directory right above the src directory
moddir=$(dirname "$sourcef")
while [[ "$moddir" != "/" && ! -d "$moddir/src" ]]; do
	moddir=$(dirname "$moddir")
done

if [[ "$moddir" == "/" ]]; then
	echo "could not find module directory for source file $sourcef"
	exit 1
fi

# the workspace dir is the directory right above the module directory
wsdir=$(dirname "$moddir")

while test $# -gt 0
do
    case "$1" in
		--verbose|-v|--debug) 
			verbose=true
		;;
		--help|-h)
			echo "Usage:"
			echo "$0 source_file.java [--filter <string>]"
			echo "will list the local dependencies of the source file, and show the corresponding source files in the workspace directory"
			exit 0
		;;
		--filter)
			shift
			filter="$1"
		;;
        *) echo "bad option $1"
        	exit 1
	    ;;
    esac
    shift
done

echo "listing local dependencies of $sourcef in module $moddir ..."
imports=0
match_count=0

# list the import statements in the source file, and for each import, show corresponding source files in the workspace directory
grep '^import ' "$sourcef" | while read -r import; do
    class=$(echo "$import" | sed -e 's/^import //' -e 's/;//')
	
	if [[ "$verbose" == "true" ]]; then
		echo "import: $class"
	fi
	
	imports=$((imports+1))
    path="${class//.//}.java"
	class_name=$(basename "$path")

    classpath=$(find "$wsdir" -name "$class_name")
	if [[ -z "$classpath" ]]; then
		continue
	fi

	# if a filter is specified, only show the classpath if it matches the filter
	if [[ -n "$filter" ]]; then
		if [[ "$classpath" == *"$filter"* ]]; then
			echo "└ ${classpath/$wsdir/}"
			match_count=$((match_count+1))
		fi
	else
		echo "└ ${classpath/$wsdir/}"
		match_count=$((match_count+1))
	fi
done

echo "found $imports import statements in $sourcef"
echo "matched $match_count import statements"
