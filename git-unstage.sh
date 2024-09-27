#!/bin/bash

path="$1"

git restore --staged "$path"
git status
