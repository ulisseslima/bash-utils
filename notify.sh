#!/bin/bash
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

source $(real require.sh)

message="$1"
require message

notifier=$(which notify-send)
require -f notifier

$notifier "$message"
