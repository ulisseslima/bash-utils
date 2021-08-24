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

operand=+
while test $# -gt 0
do
    pre=$(echo $v | rev | cut -d'.' -f2- | rev)
    build=$(echo $v | rev | cut -d'.' -f1 | rev)
	case "$1" in
		+)
			v="${pre}.$((build+1))"
            echo $v
		;;
		-)
			v="${pre}.$((build-1))"
            echo $v
		;;
		*) 
			err "unrecognized option: $1"
            err "input examples: +1 -2"
			exit 1
		;;
	esac
	shift
done
