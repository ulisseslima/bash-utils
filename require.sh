#!/bin/bash
# tests a if a required variable name is not empty, just source this script into yours

function llog() {
    >&2 echo "$@"
}

require() {
    switch='-s'
    if [[ "$1" == *'-'* ]]; then
        switch=$1
        shift
    fi

	local keyname="$1"
	local value="${!keyname}"
	local info="$2"

    case $switch in
        --string|-s)
            if [ ! -n "$value" ]; then
                llog "required variable has no value: $keyname = '$info'"
                exit 1
            fi
        ;;
        --file|-f)
            if [ ! -f "$value" ]; then
                llog "a required file was not found: '$value' (varname: $keyname) - $info"
                exit 2
            fi
        ;;
        --dir|-d)
            if [ ! -d "$value" ]; then
                llog "a required dir was not found: '$value' (varname: $keyname) - $info"
                exit 3
            fi
        ;;
    esac
}
