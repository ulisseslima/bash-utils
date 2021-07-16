#!/bin/bash -e

root="$(git rev-parse --show-toplevel)"
cd $root

while read ref
do
        commit_id=$(echo $ref | cut -d' ' -f2)
        git diff-tree --no-commit-id --name-only -r ${commit_id}
done < <(git cherry -v)
