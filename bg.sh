#!/bin/bash
# runs something in the background, saving logs to /tmp/executable-name.log
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

nohup "$1" &> "/tmp/$1.log"&