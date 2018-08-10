#!/bin/bash -e

do_help() {
  echo "constantly prints the size of a file, then exits when it stops changing"
  echo "usage: "
  echo "$0 /some/file"
}

file="$1"

if [ ! -n "$file" ]; then
  echo "first argument must be a file or directory"
  exit 1
fi

last=0

while true
do
  atual=$(du -s "$file")
  echo "$atual"

  if [ "$atual" == "$last" ]; then
    exit 0
  fi

  last="$atual"

  sleep 2
done
