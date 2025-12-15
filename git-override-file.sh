#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF >&2
Usage: $0 <local-path> <remote-branch> [remote]

Overrides a single file in the current branch with the contents of
`<remote>/<remote-branch>`.

Examples:
  $0 src/main.c feature-branch
  $0 README.md other-branch upstream

This command fetches the remote branch then checks out the file from
the remote branch into the working tree. It does not create a commit;
run `git add <path> && git commit -m "Override <path> from <remote>/<branch>"`
to commit the change. Remote defaults to "origin" if not specified.
EOF
  exit 2
}

if [ "$#" -lt 2 ]; then
  usage
fi

local_path="$1"
branch="$2"
remote="${3:-origin}"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: not inside a git repository." >&2
  exit 1
fi

echo "Fetching ${remote}/${branch}..."
git fetch "${remote}" "${branch}"

echo "Checking for '${local_path}' in ${remote}/${branch}..."
if git show "${remote}/${branch}:${local_path}" >/dev/null 2>&1; then
  echo "Overriding '${local_path}' with ${remote}/${branch}..."
  git checkout "${remote}/${branch}" -- "${local_path}"
  echo "Done: '${local_path}' updated in working tree."
  echo "To commit: git add -- '${local_path}' && git commit -m \"Override ${local_path} from ${remote}/${branch}\""
else
  echo "Error: path '${local_path}' does not exist in ${remote}/${branch}." >&2
  exit 3
fi
