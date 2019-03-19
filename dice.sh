#!/bin/bash

start=${1:-0}
end=${2:-5}

cat /dev/urandom | tr -dc "${start}-${end}" | fold -w 1 | head -n 1
