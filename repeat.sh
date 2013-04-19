#!/bin/bash -e

command="$1"
times="$2"
delay="$3"

for (( i=1; i<=$times; i++ ))
do
  $command
  sleep $delay
done
