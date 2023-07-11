#!/bin/bash
# cherry picks a commit from any branch
# https://stackoverflow.com/questions/881092/how-to-merge-a-specific-commit-in-git
source $(real require.sh)

commit=$1
require commit

git cherry-pick $commit
