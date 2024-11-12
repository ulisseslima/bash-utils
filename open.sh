#!/bin/bash

if [[ -t 0 ]]; then
	xdg-open "$@"
else
	xdg-open $(cat /dev/stdin)
fi

