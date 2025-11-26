#!/bin/bash
# simple stopwatch that can be reset
# usage: stop-watch.sh [reset]
reset=${1:-false}
timerf=/tmp/timer

if [[ $reset == new || ! -f $timerf ]]; then
    echo starting new timer
    start=$(($(date +%s%N)/1000000))
    echo $start > $timerf
else
    echo reusing timer
    start=$(cat $timerf)
fi

end=$(($(date +%s%N)/1000000))
elapsed_ms=$(($end-$start))

echo $elapsed_ms
