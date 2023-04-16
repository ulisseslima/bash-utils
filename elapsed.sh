#!/bin/bash
# e.g.:
# start=$(elapsed.sh)
# elapsed.sh $start

start="$1"
if [[ -z "$start" ]]; then
	millis=$(($(date +%s%N)/1000000))
	echo "$millis"

	exit 0
fi

end=$(($(date +%s%N)/1000000))
elapsed_ms=$(($end-$start))

if [[ "$2" == -s ]]; then
	echo $((elapsed_ms/1000))
elif [[ "$2" == --minutes ]]; then
	echo $((elapsed_ms/1000/60))
elif [[ "$2" == --hours ]]; then
	echo $((elapsed_ms/1000/60/60))
else
	echo $elapsed_ms
fi
