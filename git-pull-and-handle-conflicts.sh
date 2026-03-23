#!/bin/bash -e
# stash local changes, pull remote changes, and show conflicts if any
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

source $(real require.sh)

git stash
git pull
git stash pop
