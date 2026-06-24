#!/bin/bash
# useful to show commits ahead of the target branch

currbranch=$(git-curr-branch.sh)
branch=${1:-${currbranch}}

echo "$branch - diffs"

git log --oneline origin/${branch}..HEAD

