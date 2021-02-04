#!/bin/bash
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

resource="$1"

if [[ ! -f "$resource" ]]; then
    if [[ ! -d "$resource" ]]; then
        err "'$resource' is not a file or directory"
        exit 1
    fi
fi

echo "checking exclusion rules for '$resource' ..."
r=$(git check-ignore -v -- "$resource")
if [[ -n "$r" ]]; then
    echo "'$resource' is already checked"
    echo "$r"
    exit 1
fi

echo "removing '$resource' from cache ..."
git rm -r --cached "$resource"

echo "re-checking exclusion rules for '$resource' ..."
git check-ignore -v -- "$resource"
