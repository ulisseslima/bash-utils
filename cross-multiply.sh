#!/bin/bash

k1=$1
k2=$2
u=$3

echo "if"
echo "$k1 = $k2"
echo "then"
echo "$u = x"
echo "therefore..."

#u1=$(($u*$k2))
u1=$(echo "scale=9; $u*$k2" | bc)
x=$(echo "scale=9; $u1/$k1" | bc)

echo "($u * $k2) / $k1"
echo "x = $x"
