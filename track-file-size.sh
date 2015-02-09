#!/bin/bash -e

if [ "$1" == "--help" ]; then
  echo 'keeps track of a file or directory'
  echo 'the size is shown every $2 seconds'
  exit 0
fi

file=$1
delay=$2

while true
do
  du -sh "$file"
  sleep $delay
done
