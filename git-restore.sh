#!/bin/bash
# restore deleted files

f="$1"
#git status | grep $f
git checkout -- "$f"
