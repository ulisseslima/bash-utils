#!/bin/bash
# use when you forgot to stage some files from the last commit

msg="$1"

if [[ -n "$msg" ]]; then
	git commit --amend -m "$1"
else
	git commit --amend --no-edit
fi
