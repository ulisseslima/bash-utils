#!/bin/bash
# to find commit id:
# git log --inline

source $(real require.sh)

commit_id=$1
require commit_id

git revert $commit_id
git push
