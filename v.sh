#!/bin/bash

v="$1"
shift

function err() {
    >&2 echo "$@"
}

if [[ $(nan.sh "$v") == true ]]; then
    err "nan: '$v'"
    exit 1
fi

while test $# -gt 0
do
	case "$1" in
		+*)
			shift
			v="$1"
		;;
		-*)
			shift
			msg="$1"
		;;
		*) 
			err "unrecognized option: $1"
            err "input examples: +1 -2"
			exit 1
		;;
	esac
	shift
done

pre=$(echo $v | rev | cut -d'.' -f2- | rev)
build=$(echo $v | rev | cut -d'.' -f1 | rev)
echo "${pre}.$((build+1))"