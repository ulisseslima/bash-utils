#!/bin/bash

k1=$1
k2=$2
u=$3

info() {
	>&2 echo "$@"
}

info "if"
info "$k1 = $k2"
info "then"
info "$u = x"
info "therefore..."

#u1=$(($u*$k2))
u1=$(echo "scale=9; $u*$k2" | bc)
x=$(echo "scale=9; $u1/$k1" | bc)

info "($u * $k2) / $k1"
info "x ="
echo $x
