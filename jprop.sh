#!/bin/bash
export PYTHONIOENCODING=utf-8

py=$(which python2)
if [[ -n "$py" ]]; then
  cat /dev/stdin | $py -c "import sys, json; print json.load(sys.stdin)$1"
else
  py=$(which python)
  [[ -z "$py" ]] && py=python3
  # end='' -> remove this to include a line break
  cat /dev/stdin | $py -c "import sys, json; y = json.load(sys.stdin); print(y$1, end='')"
fi
