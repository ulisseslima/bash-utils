#!/bin/bash

source="$1"
pattern="$2"

if [ ! -d "$source" ]; then
	echo "first arg must be the source dir"
	exit 1
fi

if [ ! -n "$pattern" ]; then
	echo "pattern to delete is required"
	exit 1
fi

echo "will delete all files with pattern '$pattern' in '$source'"
echo "press <enter> to continue or ctrl+c to cancel..."
read input

find "$source" -type f -name "$pattern" -delete
