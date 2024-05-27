#!/bin/bash -e
# delete branch locally and (optionally) remotely
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

source $(real require.sh)

branch=$1
require branch

remote=${2:-false}

echo "deleting branch locally..."
git branch -d $branch

if [[ "$remote" == true ]]; then
    echo "deleting branch remotely..."
    git push origin --delete $branch
fi