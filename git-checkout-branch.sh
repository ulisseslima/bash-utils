#!/bin/bash -e
# checks out a remote branch by name
# https://stackoverflow.com/questions/1783405/how-do-i-check-out-a-remote-git-branch

source $(real require.sh)

branch=$1
require branch
shift

if [[ "$branch" == *':'* ]]; then
  # considering format user:branch from github
  branchx=$(echo "$branch" | cut -d':' -f2)
  fork=$(echo "$branch" | cut -d':' -f1)
  branch=$branchx
fi

while test $# -gt 0
do
    case "$1" in
	# use only if fork project name differs from original
        --repo)
	    shift
            repo="$1"
        ;;
	# optional fork owner github name
        --fork)
	    shift
            fork="$1"
        ;;
        -*)
            echo "unrecognized option: $1"
            exit 1377
        ;;
    esac
    shift
done

git pull
if [[ -z "$fork" ]]; then
  git fetch --all
else
  FORK_REMOTE_NAME="fork-${fork}"
  if [[ -n "$repo" ]]; then
    REPO=$repo
  else
    REPO=$(basename $(git-root.sh))
  fi

  FORK_REPO_URL="https://github.com/${fork}/${REPO}.git"

  if git remote | grep -q "$FORK_REMOTE_NAME"; then
    echo "Remote $FORK_REMOTE_NAME already exists."
  else
    echo "Adding remote $FORK_REMOTE_NAME..."
    git remote add "$FORK_REMOTE_NAME" "$FORK_REPO_URL"
  fi

  git fetch "$FORK_REMOTE_NAME" "$branch"
  #git checkout -b "$BRANCH_NAME" --track "$FORK_REMOTE_NAME/$BRANCH_NAME"
fi
git switch $branch
