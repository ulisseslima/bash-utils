#!/bin/bash
mydir=$(dirname `readlink -f $0`)

node $mydir/breakpow2.js "$@"
