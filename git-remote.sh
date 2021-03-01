#!/bin/bash

branch=$(git branch --show-current)
origin="origin"
f=''

while test $# -gt 0
do
    case "$1" in
        --help)
            do_help
        ;;
        --origin|-o)
            shift
            origin="$1"
        ;;
        --branch|-b)
            shift
            branch="$1"
        ;;
        --file|-f)
            shift
            f="$1"
        ;;
        *)
            echo "bad option: '$1'"
            exit 1
        ;;
    esac
    shift
done

url=$(git remote get-url $origin)
url="${url/.git/}"
if [[ -n "$f" ]]; then
    branch_path="/-/blob/$branch/"
    full_link="${url}${branch_path}$(git ls-files --full-name "$f")"
    echo "${full_link}"
else
    echo ${url}
fi
