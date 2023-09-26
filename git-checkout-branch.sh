#!/bin/bash
# https://stackoverflow.com/questions/1783405/how-do-i-check-out-a-remote-git-branch

source $(real require.sh)

branch=$1
require branch

git fetch --all
git switch $branch
