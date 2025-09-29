#!/bin/bash
# cherry picks a commit from any branch
# https://stackoverflow.com/questions/881092/how-to-merge-a-specific-commit-in-git
source $(real require.sh)

commit="$1"
require commit

# note: if it fails, try specifying -m 1 before the commit hash
# note: if "fatal: bad object", try git fetch
git pull
git cherry-pick $commit
