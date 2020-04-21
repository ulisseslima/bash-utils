#!/bin/bash
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

logf=/tmp/general.log

function debugging() {
    verbose=${1}

    PARENT_COMMAND=$(ps -o comm= $PPID)
    if [[ ! -n "$PARENT_COMMAND" || "$PARENT_COMMAND" == "bash" ]]; then
        PARENT_COMMAND=$ME
    fi

    debugf=/tmp/${PARENT_COMMAND}.conf.d/debug
    if [ ! -f $debugf ]; then
        mkdir -p "$(dirname $debugf)"
        echo off > $debugf
    fi

    if [[ -n "$verbose" ]]; then
        echo $verbose > $debugf
    else
        cat $debugf
    fi
}

function log() {
    level="$1"
    shift

    indicator="$1"
    shift

    echo "$indicator $(now.sh -dt) - ${FUNCNAME[2]}@${BASH_LINENO[1]}/$level: $@"
    echo "$MYSELF - $indicator $(now.sh -dt) - ${FUNCNAME[2]}@${BASH_LINENO[1]}/$level: $@" >> $logf
}

function info() {
    log INFO '###' "$@"
}

function err() {
    >&2 log ERROR '!!!' "$@"
}

function debug() {
    if [[ $(debugging) == on ]]; then
        >&2 log DEBUG '>>>' "$@"
    fi
}

case "$1" in
    --info)
        shift
        info "$@"
    ;;
    --error)
        shift
        err "$@"
    ;;
    --debug)
        shift
        if [[ "$1" == on || "$1" == off ]]; then
            debugging $1
        else
            debug "$@"
        fi
    ;;
esac
