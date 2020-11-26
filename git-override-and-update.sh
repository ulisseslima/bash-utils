#!/bin/bash

branch="${1:-master}"
c="git reset --hard origin/$branch"
echo $c
$c
