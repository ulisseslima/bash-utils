#!/bin/bash

sum=0
while read line
do
	n=${line//[!0-9]/}
	sum=$((sum+n))
done < /dev/stdin

echo $sum
