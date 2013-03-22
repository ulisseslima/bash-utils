#!/bin/sh

curr_version=`cat control | grep 'Version' | cut -d: -f2 | tr -d 'u' | tr -d ' '`

echo "Current version: '$curr_version'"
