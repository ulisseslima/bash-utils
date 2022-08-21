#!/bin/bash
# returns the percentage of a value
# optionally, runs a math operation

in="$1"
shift
percent=$1
shift

op=
round=false

while test $# -gt 0
do
    case "$1" in
    --verbose|-v)
        verbose=true
    ;;
    --op)
        shift
        op="$1"
    ;;
    --round)
        round=true
    ;;
    -*)
        echo "bad option '$1'"
    ;;
    esac
    shift
done

if [[ -z "$in" || -z "$percent" ]]; then
    echo "usage (30% of 600): "
    echo "$0 600 30"
    exit 1
fi

diff=$(cross-multiply.sh 100 $in $percent x)
if [[ -z "$op" ]]; then
    echo $diff
    exit 0
fi

value=$(echo "scale=2; ${in}${op}${diff}" | bc)
if [[ $round == true ]]; then
    round.sh $value
else
    echo $value
fi