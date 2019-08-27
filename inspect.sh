#!/bin/bash

PID=$1

if [ ! -n "$PID"]; then
	echo "first arg must be the process ID to inspect"
	exit 1
fi

strace -p $PID -s 80 -o /tmp/debug.log
