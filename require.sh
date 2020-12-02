#!/bin/bash

function log() {
    level="$1"
    shift

    indicator="$1"
    shift

    echo "$indicator $(now.sh -dt) - $level: $@"
    echo "$MYSELF - $indicator $(now.sh -dt) - $level: $@" >> /tmp/general.log
}

function info() {
    log INFO '###' "$@"
}

function err() {
    >&2 log ERROR '!!!' "$@"
}

function debug() {
    if [[ "$verbose" == true ]]; then
        >&2 log DEBUG '>>>' "$@"
    fi
}

require() {
        switch='-s'
        if [[ "$1" == *'-'* ]]; then
            switch=$1
            shift
        fi

	keyname="$1"
	value="${!keyname}"
	info="$2"

        case $switch in
          --string|-s)
                if [ ! -n "$value" ]; then
                    log "required variable has no value - $keyname: $info"
                    return 1
                fi
          ;;
          --file|-f)
                    if [ ! -f "$value" ]; then
                        log "an expected file was not found: '$value' (varname: $keyname) - $info"
                        return 2
                fi
          ;;
          --dir|-d)
                if [ ! -d "$value" ]; then
                    log "an expected dir was not found: '$value' (varname: $keyname) - $info"
                    return 3
                fi
          ;;
        esac
}

#test $# -gt 0 && require "$@"
