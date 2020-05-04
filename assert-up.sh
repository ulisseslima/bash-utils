#!/bin/bash -e
# assert an address is up. if it isn't, exit with non zero status
address="$1"
if [[ ! -n "$address" ]]; then
	echo "first arg must be address to check"
	exit 1
fi

curl -sSf "$address" > /dev/null
