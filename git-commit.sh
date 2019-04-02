#!/bin/bash -e

message="$1"
if [ ! -n "$message" ]; then
	echo "first arg must be commit message"
	exit 1
fi

if [ ! -f ./.gitignore ]; then
	echo ".gitignore not found. create and try again."
	exit 1
fi

echo "pulling..."
git pull

echo "adding new files..."
git add .

echo "commiting..."
git commit -a -m "$message"

echo "pushing..."
git push
