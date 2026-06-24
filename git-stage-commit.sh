#/bin/bash
# receive a commit id, create a new branch from that commit for local testing

if [ -z "$1" ]; then
  echo "Usage: $0 <commit-id>"
  exit 1
fi

commit_id=$1
branch_name="test-branch-$commit_id"

# git checkout -b "$branch_name" "$commit_id"
git checkout -b "$branch_name"
git-cherry-pick.sh "$commit_id"
