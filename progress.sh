#!/bin/bash
# like tail -f, but updates on the same line
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

source $(real require.sh)

rate=.5
tmpf="/tmp/progress-$(basename "$1").log"

function shutdown() {
  tput cnorm # reset cursor
}
trap shutdown EXIT

function cursorBack() {
  echo -en "\033[$1D"
}

function do_wait() {
  local pid=$1

  local i=0
  while kill -0 $pid 2>/dev/null; do
    content=$(tail -n 1 "$tmpf")
    cpu_load=$(top -b -n 1 | head -1)
    cpu_use=$(top -b -n 1 | tail -n +8 | awk '{print $1, $9, $12}' | head -1)

    printf "\r%s | %s | %s" "$content" "$cpu_load" "$cpu_use"
    sleep $rate
  done
  
  wait $pid # capture exit code
  echo ""
  return $?
}

("$@") > $tmpf 2>&1 &

do_wait $!
