#!/bin/bash
# sum the values from lines in a file. ignores comments.

finput="${1:-/dev/stdin}"

sum=0
while read line
do
	n=${line//[!0-9.]/}
	sum=$(echo "scale=2; ${sum}+${n}" | bc)
done < <(cat $finput | grep -v '#')

echo $sum
