#!/bin/bash -e
# move commit to another branch
# [not tested yet]
# git-mv-commit.sh 7360578 --to another_branch
source $(real require.sh)

commit_id=$1
require commit_id
shift

curr_branch=$(git-curr-branch.sh)

while test $# -gt 0
do
    case "$1" in
        --to)
		shift
		target_branch="$1"
        ;;
        -*)
            echo "unrecognized option: $1"
            exit 1377
        ;;
    esac
    shift
done

require target_branch

git checkout $target_branch
git cherry-pick $commit_id

git checkout $curr_branch
git reset --hard HEAD~1

