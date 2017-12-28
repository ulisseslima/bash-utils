#!/bin/bash

in="$1"

regex='^[0-9]+$'
if ! [[ "$in" =~ $regex ]] ; then
	echo true
else
	echo false
fi
