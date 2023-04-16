#!/bin/bash

r=47
g=82
b=107

#72.34%	37.80%	20.56%

triangles='81,113,129
71,101,113
103,133,141
219,226,207
205,214,198
191,196,187
195,201,191'

function transpose() {
	# original
	a=$2

	# new number
	b=$1

	d=$((a-b))
	echo "diff: $d"

	d=$(inline-java.sh 'println((n[0]/n[1]));' $d $a)

	p=$(inline-java.sh 'println((n[0])*100);' $d)
	echo "$p%"
}

transpose $1 $2
