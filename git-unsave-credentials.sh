#!/bin/bash -e
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

git config --global --unset credential.helper

echo "remove ~/.git-credentials manually:"
cat ~/.git-credentials
