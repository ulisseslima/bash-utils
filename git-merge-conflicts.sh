#!/bin/bash -e
# show conflicting local changes vs remote incoming changes before merge
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

echo "Fetching remote..."
git fetch

# files changed locally (staged or unstaged)
local_changed=$(
  { git diff --name-only; git diff --name-only --cached; } | sort -u
)

# files changed between local HEAD and remote tracking branch
remote_changed=$(git diff --name-only HEAD @{u} 2>/dev/null)

if [[ -z "$remote_changed" ]]; then
  echo "No changes on remote. Nothing would conflict."
  exit 0
fi

# intersection: files changed both locally and on remote
conflicts=$(comm -12 \
  <(echo "$local_changed") \
  <(echo "$remote_changed" | sort))

if [[ -z "$conflicts" ]]; then
  echo "No conflicting files found."
  exit 0
fi

echo ""
echo "Conflicting files:"
echo "$conflicts" | sed 's/^/  /'
echo ""

while IFS= read -r file; do
  echo "=========================================="
  echo "FILE: $file"
  echo "=========================================="

  echo ""
  echo "--- YOUR LOCAL CHANGES ---"
  git diff HEAD -- "$file" 2>/dev/null || true
  git diff --cached -- "$file" 2>/dev/null || true

  echo ""
  echo "--- INCOMING REMOTE CHANGES ---"
  git diff HEAD @{u} -- "$file" 2>/dev/null || true

  echo ""
done <<< "$conflicts"
