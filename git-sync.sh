#!/bin/bash -e
# sync with remote branch
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

source $(real require.sh)

while test $# -gt 0
do
    case "$1" in
    --target|--with)
        shift
        target="$1"
    ;;
    -*)
        echo "bad option '$1'"
        exit 1
    ;;
    esac
    shift
done

require target

current=$(git-curr-branch.sh)
if [[ "$target" == "$current" ]]; then
    err "target cannot be the same as the current branch"
    exit 1
fi

info "syncing with $target ... from $current"

git checkout $target
git pull
git checkout $current
git merge $target
if [[ $(git status | grep -ci 'Your branch is ahead' || true) -gt 0 ]]; then
    info "detected $current ahead of $target, pushing changes"
    git push
fi

info "$current is synced with $target"
