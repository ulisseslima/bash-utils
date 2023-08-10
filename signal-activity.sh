#!/bin/bash -e
# keeps the pc not idle so it doesn't suspend from inactivity
# https://askubuntu.com/questions/1323618/how-to-disable-auto-suspend-temporary-reset-idle-time
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

trap 'catch $? $LINENO' ERR
catch() {
  if [[ "$1" != "0" ]]; then
    >&2 echo "$ME - returned $1 at line $2"
  fi
}

xdotool mousemove 0 0 mousemove restore
