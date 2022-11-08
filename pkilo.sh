#!/bin/bash
# returns the price per kilo

round=true

while test $# -gt 0
do
    case "$1" in
    --verbose|-v)
        verbose=true
    ;;
    --precision)
        round=false
    ;;
    --kilos|-k)
	shift
        kilos="$1"
    ;;
    --price|-p)
	shift
        price="$1"
    ;;
    -*)
        echo "bad option '$1'"
    ;;
    esac
    shift
done

value=$(echo "scale=2; 1*${price}/${kilos}" | bc)
echo $value
