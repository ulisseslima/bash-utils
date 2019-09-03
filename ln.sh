#!/bin/bash

MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

app=$1

if [ ! -n "$app" ]; then
	echo "$0: faster way o put an app on PATH"
	echo "- takes an app from the current directory"
	echo "- marks it as executable"
	echo "- creates a link to it on /usr/bin"
	echo ""
	echo "first argument must be the app path (can be relative to working directory)"
	exit 0
fi

if [ ! -f "$app" ]; then
	echo "not a file: $app"
	exit 1
fi

abs="$(readlink -f $app)"
app_name=$(basename "$abs")
if [ -f "$(real $app)" ]; then
	echo "$app is already on PATH"
	exit 0
fi

sudo chmod +x "$abs" && \
sudo ln -s "$abs" /usr/local/bin/$app_name

ls -la $app_name

echo "tesing new link..."
$app_name
