#!/bin/bash -e

if [[ ! -n "$1" ]]; then
	echo "provide a command to repeat"
	exit 1
fi

if [[ "$1" == "--help" ]]; then
	echo "usage:"
	echo "$0 'some command' 5 10"
	echo "will execute the provided command 5 times, waiting 10 seconds between each execution"
fi

command="$1"
times="$2"
delay="$3"

for (( i=1; i<=$times; i++ ))
do
  $command
  sleep $delay
done
