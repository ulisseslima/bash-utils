#!/bin/bash

start="$1"
if [ ! -n "$start" ]; then
	echo $(($(date +%s%N)/1000000))
	exit 0
fi

end=$(($(date +%s%N)/1000000))
elapsed_ms=$(($end-$start))

echo $elapsed_ms
