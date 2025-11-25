#!/bin/bash

set -euo pipefail

usage() {
	echo "Usage: $0 [MODULE] [options]"
	echo "Prints Maven profiles and their modules from pom.xml."
	echo
	echo "Positional arguments:" 
	echo "  MODULE              optional module name to filter profiles that contain it"
	echo
	echo "Options:"
	echo "  -o, --only-module   when used with MODULE, print only the MODULE (and profile id) instead of full module lists"
	echo "  -h, --help          show this help message and exit"
}

MODULE=""
ONLY_SELECTED=false

while [ "$#" -gt 0 ]; do
	case "$1" in
		-h|--help)
			usage
			exit 0
			;;
		-o|--only-module)
			ONLY_SELECTED=true
			shift
			;;
		--)
			shift
			break
			;;
		-* )
			echo "Unknown option: $1" >&2
			usage
			exit 1
			;;
		*)
			if [ -z "$MODULE" ]; then
				MODULE="$1"
			else
				echo "Unexpected argument: $1" >&2
				usage
				exit 1
			fi
			shift
			;;
	esac
done

NS="-N x=http://maven.apache.org/POM/4.0.0"

if [ "$ONLY_SELECTED" = true ] && [ -z "$MODULE" ]; then
	echo "The -o/--only-module option requires a MODULE argument." >&2
	usage
	exit 1
fi

if [ -n "$MODULE" ]; then
	if [ "$ONLY_SELECTED" = true ]; then
		xmlstarlet sel $NS -t -m "//x:project/x:profiles/x:profile[x:modules/x:module = '$MODULE']" -v "concat(x:id, ': ', '$MODULE')" -n pom.xml
	else
		xmlstarlet sel $NS -t -m "//x:project/x:profiles/x:profile[x:modules/x:module = '$MODULE']" -v "concat(x:id, ': ', x:modules)" -n pom.xml
	fi
else
	xmlstarlet sel $NS -t -m "//x:project/x:profiles/x:profile" -v "concat(x:id, ': ', x:modules)" -n pom.xml
fi
