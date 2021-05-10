#!/bin/bash
export PYTHONIOENCODING=utf-8

py=$(which python2)
[[ -z "$py" ]] && py=$(which python)

cat /dev/stdin | $py -c "import sys, json; print json.load(sys.stdin)$1"
