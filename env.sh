#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: env.sh <key-part>" >&2
  exit 2
fi

key="$1"

line=$(env | grep -i -- "$key" | head -n1 || true)
if [ -z "$line" ]; then
  echo "No match for '$key' in environment" >&2
  exit 1
fi

value="${line#*=}"

# Try common clipboard tools: wl-copy (Wayland), xclip, xsel, pbcopy (mac)
if command -v wl-copy >/dev/null 2>&1; then
  printf '%s' "$value" | wl-copy
elif command -v xclip >/dev/null 2>&1; then
  printf '%s' "$value" | xclip -selection clipboard
elif command -v xsel >/dev/null 2>&1; then
  printf '%s' "$value" | xsel --clipboard --input
elif command -v pbcopy >/dev/null 2>&1; then
  printf '%s' "$value" | pbcopy
else
  # No clipboard utility found: print value and warn
  printf '%s\n' "$value"
  echo "Warning: no clipboard tool found (tried wl-copy, xclip, xsel, pbcopy)" >&2
  exit 3
fi

exit 0
