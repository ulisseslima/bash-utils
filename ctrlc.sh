#!/bin/bash

in=/dev/stdin
if [[ -n "$1" ]]; then
  if [[ "$1" == -v ]]; then
	verbose=true
  else
	in=$(real "$1")
  fi
fi


contents=$(cat $in)
printf "$contents" | xclip -sel clip
if [[ "$verbose" == true ]]; then
	echo "$contents => copied to clipboard"
fi
