#!/bin/bash -e
# activates credential saving globally
# create access tokens: https://github.com/settings/tokens
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

git config --global credential.helper store
echo "provide credentials to save:"
git pull
