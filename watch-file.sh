#!/bin/bash -e

do_help() {
  echo "constantly prints the size of a file, then exits when it stops changing"
  echo "usage: "
  echo "$0 /some/file"
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
  actual=$(du -s "$file" | tr '\t' ' ' | cut -d' ' -f1)
  diff=$(op.sh ${last}-${actual})
  mb=$(op.sh "round($diff/1024.0, 2)")

  printf "\r$(now.sh -dt) - $actual bytes ($mb mb per minute)"

  if [ "$actual" == "$last" ]; then
    echo "
	- no change detected, exiting..."
    exit 0
  fi

  last="$actual"
  sleep $sleep
done
