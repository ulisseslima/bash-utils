#!/bin/bash
# decode an access token
# https://jwt.io/
jq -R 'split(".") |.[0:2] | map(gsub("-"; "+") | gsub("_"; "/") | gsub("="; "=") | @base64d) | map(fromjson)' <<< $1

