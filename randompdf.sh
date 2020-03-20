#!/bin/bash

pages=${1:-10}
w=${2:-500}
h=${3:-700}

echo "creating pdf with $pages pages, dimensions ${w}x${h}"

name="rnd-${pages}_${w}-${h}"
tmp="/tmp/$name"
mkdir -p $tmp

for (( i=1; i<=$pages; i++ ))
do
	randompx.sh $w $h "$tmp/${i}.jpg"
done

convert $tmp/*.jpg $name.pdf
echo "created $(readlink -f $name.pdf)"

rm -rf $tmp
