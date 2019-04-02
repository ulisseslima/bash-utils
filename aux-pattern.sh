#!/bin/bash

pattern="$1"
if [ ! -n "$pattern" ]; then
	echo "first arg must be the field pattern to find"
	exit 1
fi

ps aux | grep java | tr -s ' ' | sed -n -e "s/^.*${pattern}//p" | cut -d' ' -f1
