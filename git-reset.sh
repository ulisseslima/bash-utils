#!/bin/bash
# resets (undo) the last commit in this branch
# useful when commited to the wrong branch
# https://stackoverflow.com/questions/2941517/how-to-fix-committing-to-the-wrong-git-branch
git reset --soft HEAD^
git status

# to re-commit in a new branch:
#git commit -c ORIG_HEAD
