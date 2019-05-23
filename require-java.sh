#!/bin/bash

if [ ! -f $(which java-version.sh) ]; then
	echo "this script depends on java-version.sh"
	exit 1
fi

required=$1

v=$(java-version.sh)
if [[ "$v" -ne "$required" ]]; then
	echo "java $v detected, $required required"
	exit 1
fi
