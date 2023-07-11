#!/bin/bash
# shows current timezone. sets timezone to $1 if specified
timedatectl
tz="$1"
if [[ -n "$tz" ]]; then
	echo "set timezone to $tz?"
	read confirmation

	sudo timedatectl set-timezone $1
fi
