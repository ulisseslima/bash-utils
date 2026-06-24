#!/bin/bash

currbranch=$(git-curr-branch.sh)
branch=${1:-${currbranch}}

echo "$branch - diffs"
git diff --name-only $branch...HEAD
