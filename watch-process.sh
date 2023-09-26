#!/bin/bash -e

do_help() {
  echo "constantly prints the top result for a command, then exits when it stops changing"
  echo "usage: "
  echo "$0 some-long-running-command"
}

file="$1"

if [[ ! -n "$file" ]]; then
  echo "first argument must be a file or directory"
  exit 1
fi

sleep=60

last=0
speed=0
written=0
while true
do
  actual=$(top | grep -m1 "$file")

  printf "\r$(now.sh -dt) $actual"

  if [ "$actual" == "$last" ]; then
    echo "
	- no change detected, exiting..."
    exit 0
  fi

  last="$actual"
  sleep $sleep
done
