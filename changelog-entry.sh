#!/bin/bash

changelog="$1"
if [ ! -f "$changelog" ]; then
        echo "arg1 is not a file: '$changelog'"
        exit 1
fi

msg="$2"
if [ ! -n "$msg" ]; then
        echo "arg2 must be the changelog message"
        exit 1
fi

v=$(grep '## \[' $changelog | tr ']' '[' | cut -d'[' -f2 | tail -1)
if [ ! -n "$v" ]; then
        echo "couldn't figure out latest version from changelog, is it using mardown format?"
        exit 1
fi

today=$(now.sh --date)
echo "today: $today"
echo "version: $v"

echo "adding changelog message: $msg"
echo "- @$USER - ${msg}" >> $changelog
