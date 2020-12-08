#!/bin/bash
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

logf=$HOME/general.log

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

	if [[ "$1" == '-n' ]]; then
		echo ""
		shift
	fi

    if [[ $level == DEBUG && $(debugging) == on || $level != DEBUG ]]; then
    	echo "$indicator $(now.sh -dt) - ${FUNCNAME[2]}@${BASH_LINENO[1]}/$level: $@"
    fi
    echo "$MYSELF - $indicator $(now.sh -dt) - ${FUNCNAME[2]}@${BASH_LINENO[1]}/$level: $@" >> $logf
}

function info() {
    >&2 log INFO '###' "$@"
}

function err() {
    >&2 log ERROR '!!!' "$@"
}

function debug() {
    >&2 log DEBUG '>>>' "$@"
}

debugging off
for var in "$@"
do
    case "$var" in
        --verbose|--debug|-v)
            shift
            debugging on
            echo "debug turned on: $debugf"
        ;;
        --quiet|-q)
            shift
            debugging off
        ;;
    esac
done
