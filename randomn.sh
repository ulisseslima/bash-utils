#!/bin/bash

size=${1:-10}

cat /dev/urandom | tr -dc "0-9" | fold -w $size | head -n 1
