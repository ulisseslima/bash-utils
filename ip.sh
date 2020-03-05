#!/bin/bash

if [ ! -n "$1" ]; then
	echo "resolves the IP of the hostnamed passed using Google's DNS (8.8.4.4)"
	echo ""
	echo "first argument must be the host"
	exit 1
fi

dns=${2:-8.8.4.4}

dig @$dns +noall +answer $1
