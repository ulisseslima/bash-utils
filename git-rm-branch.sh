#!/bin/bash
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

# if unable to delete locally, prompt user to force delete
if [[ $? -ne 0 ]]; then
	echo "unable to delete branch locally. force delete? (y/n)"
	read confirmation
	if [[ ${confirmation,,} == y* ]]; then
		echo "force deleting branch locally..."
		git branch -D $branch || true
	fi
fi

if [[ "$remote" == true ]]; then
    echo "deleting branch remotely..."
    git push origin --delete $branch
else
    remote_exists=$(git branch -r | grep -c $branch || true)
    if [[ "$remote_exists" -gt 0 ]]; then
	echo "remote branch found. delete? $(git branch -r | grep $branch)"
	read confirmation
	if [[ ${confirmation,,} == y* ]]; then
	    echo "deleting branch remotely..."
    	    git push origin --delete $branch
	fi
    fi
fi

# https://unix.stackexchange.com/questions/441442/tab-completion-for-git-branches-showing-old-outdated-entries
git remote prune origin

# https://stackoverflow.com/questions/18308535/automatic-prune-with-git-fetch-or-pull
git fetch --prune
