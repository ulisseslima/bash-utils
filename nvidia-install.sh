#!/bin/bash

if [ ! -n "$1" ]; then
	echo "first arg must be the driver version"
	echo "check on https://www.nvidia.com/object/unix.html"
	exit 1
fi

sudo apt update && sudo apt -y upgrade



sudo apt install nvidia-$1
