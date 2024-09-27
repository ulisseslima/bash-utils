#!/bin/bash -e
# @installable
# runs a script with the cron environment
# https://unix.stackexchange.com/questions/42715/how-can-i-make-cron-run-a-job-right-now-for-testing-debugging-without-changin
# first, capture cron's env with this cron script:
# * * * * *   /usr/bin/env > /tmp/cron-env
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

trap 'catch $? $LINENO' ERR
catch() {
  if [[ "$1" != "0" ]]; then
    >&2 echo "$ME - returned $1 at line $2"
  fi
}

/usr/bin/env -i $(cat /tmp/cron-env) "$@"
