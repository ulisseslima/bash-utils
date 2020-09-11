#!/bin/bash

user="$1"
if [[ ! -n "$user" ]]; then
	echo "arg 1 must be user name to add"
	exit 1
fi

sudo usermod -aG sudo $user
