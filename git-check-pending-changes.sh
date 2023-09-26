#!/bin/bash -e
# check if push/commit is pending
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

source $(real require.sh)

REPO="$1"

require -d REPO 'repository dir'
cd "$REPO"

status=$(git status)

case "$status" in
    *'git push'*)
      echo "push pending"
    ;;
    *'git add'*)
      echo "commit pending"
    ;;
esac

echo ok