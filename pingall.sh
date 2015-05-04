#!/bin/sh

export COUNTER=2
while [ $COUNTER -lt 255 ]
do
	ping $1$COUNTER -c 1 -w 400 | grep -B 1 "Lost = 0" &
	COUNTER=$(( $COUNTER + 1))
done
