#!/bin/bash

v="$1"
if [ ! -n "$v" ]; then
	echo first arg must be the tag name
	exit 1
fi

msg="$2"
if [ ! -n "$msg" ]; then
	echo second arg must be the tag message
	exit 1
fi

echo "current tags:"
git tag

echo "tagging as $v..."
git tag -a $v -m "$msg"

echo "pushing tag"
git push --tags
