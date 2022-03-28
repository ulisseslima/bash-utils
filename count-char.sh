#!/bin/bash
# count occurrences of a specific char in a string

var="$1"
sep="$2"

res="${var//[^$sep]}"
echo "${#res}"
