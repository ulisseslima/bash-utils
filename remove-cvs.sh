#!/bin/bash -e

##
# Recursively remove CVS directories from a directory
remove_cvs() {
	dir="$1"
	find "$dir" -type d -name CVS -print0 | xargs -0 /bin/rm -rf
}

if [ ! -d "$1" ]; then
	echo "o primeiro argumento deve ser um diretório existente"
	exit 1
fi

remove_cvs "$1"
