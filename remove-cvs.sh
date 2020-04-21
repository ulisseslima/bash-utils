#!/bin/bash -e
verbose=${2:-false}

function debug() {
	if [[ $verbose == -v ]]; then
  		>&2 echo "$@"	
	fi
}

##
# Recursively remove CVS directories from a directory
remove_cvs() {
	dir="$1"

	before=$(find $dir | wc -l)
	find "$dir" -type d -name CVS -print0 | xargs -0 /bin/rm -rf

	after=$(find $dir | wc -l)
	debug "$((before-after)) files removed"
}

if [ ! -d "$1" ]; then
	echo "o primeiro argumento deve ser um diretório existente"
	exit 1
fi

remove_cvs "$1"
