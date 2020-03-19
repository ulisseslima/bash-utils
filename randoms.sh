#!/bin/bash

size=${1:-10}
regex=${2:-a-zA-Z0-9}

cat /dev/urandom | tr -dc "$regex" | fold -w $size | head -n 1
