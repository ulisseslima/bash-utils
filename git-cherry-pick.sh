#!/bin/bash
# cherry picks a commit from any branch
# https://stackoverflow.com/questions/881092/how-to-merge-a-specific-commit-in-git
source $(real require.sh)

commit="$1"
require commit

# note: if "fatal: bad object", try git fetch
git pull || exit $?

cherry_pick_output="$(git cherry-pick "$commit" 2>&1)"
cherry_pick_status=$?
echo "$cherry_pick_output"

if [ $cherry_pick_status -ne 0 ] && echo "$cherry_pick_output" | grep -q "is a merge but no -m option was given"; then
  read -r -p "This commit appears to be a merge commit. Retry with '-m 1'? [y/N] " retry_as_merge

  if [[ "$retry_as_merge" =~ ^[Yy]$ ]]; then
    git cherry-pick -m 1 "$commit"
    exit $?
  fi
fi

exit $cherry_pick_status
