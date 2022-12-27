#!/bin/bash
# sum the values from lines in a file

finput="$1"

sum=0
while read line
do
	n=${line//[!0-9.]/}
	sum=$(echo "scale=2; ${sum}+${n}" | bc)
done < $finput

echo $sum
