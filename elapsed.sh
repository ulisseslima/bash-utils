#!/bin/bash

start="$1"
if [ ! -n "$start" ]; then
	>&2 echo "first arg must be start time in millis"
	exit 1
fi

end=$(($(date +%s%N)/1000000))
elapsed_ms=$(($end-$start))

echo $elapsed_ms
