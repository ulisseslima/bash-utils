#!/bin/bash
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

signal=/tmp/$ME.$1.f
touch "$signal"

if [[ $2 == stop ]]; then
	rm -f "$signal"
	exit 0
fi

while true
do
	if [[ ! -f "$signal" ]]; then
		break
	fi

	signal-activity.sh
	sleep 500
done

echo "done"
