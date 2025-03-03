#!/bin/bash

in="$1"

if [[ "$in" == '-'* ]]; then
	in=$(echo "$in" | cut -d'-' -f2)
fi

regex='^[0-9.]+$'
if ! [[ "$in" =~ $regex ]] ; then
	echo true
else
	echo false
fi
