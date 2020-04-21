#!/bin/bash
# coalesces args

val="$1"
type="$2"
fallback="$3"

if [ -n "$val" ]; then
    echo "$val"
else
    case "$type" in
        or)
            echo "$fallback"
        ;;
        *) 
            echo "bad option '$type'"
        ;;
    esac
fi