#!/bin/bash

# loops standard input with the desired command. better than xargs when file names have spaces

command="$1"
if [ ! -n "$command" ]; then
	echo "first arg must be the command to use for each line"
	exit 1
fi

while read line
do
	$command "$line"
done < /dev/stdin
