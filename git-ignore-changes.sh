#!/bin/bash
# drops/deletes/ovewrites any not pushed changes
# https://stackoverflow.com/questions/24983762/git-ignore-local-file-changes

git checkout -f
git clean -fd
