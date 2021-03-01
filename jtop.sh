#!/bin/bash

pid=$1
if [[ -z "$pid" ]]; then
	echo "arg 1 should be process name"
fi

top -c -p $(pgrep -d',' -f $pid)
