#!/bin/bash
# create branch locally and push remotely
name="$1"
if [ ! -n "$name" ]; then
	echo "first arg must be branch name"
	exit 1
fi

git checkout -b $name
git push -u origin $name
git branch --set-upstream-to=origin/$name $name
