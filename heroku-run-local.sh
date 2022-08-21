#!/bin/bash
# first you have to be inside your project

if [[ "$1" == *kill ]]; then
	pid=$(ps aux | grep heroku | grep 'pg:psql' |awk '{print $2}')
	echo "killing process $pid ..."
	kill -9 $pid
	exit 0
fi

heroku local web
