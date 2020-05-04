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

    case $switch in
      --string|-s)
        if [ ! -n "$1" ]; then
            err "$2"
            exit 1
        fi
      ;;
      --file|-f)
        if [ ! -f "$1" ]; then
            err "not a file: '$1'. $2"
            exit 1
        fi
      ;;
      --dir|-d)
        if [ ! -d "$1" ]; then
            err "not a directory: '$1'. $2"
            exit 1
        fi
      ;;
    esac
}

require "$@"
