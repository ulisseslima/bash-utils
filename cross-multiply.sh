#!/bin/bash

info() {
	if [[ $verbose == true ]]; then
		>&2 echo "$@"
	fi
}

verbose=false
scale=2

if [[ "$1" == -v ]]; then
	verbose=true
	shift
fi

if [[ "$1" == --scale ]]; then
	shift
	scale="$1"
	shift
fi

k1=$1
k2=$2
u=$3

info "if"
info "$k1 = $k2"
info "then"
info "$u = x"
info "therefore..."

#u1=$(($u*$k2))
u1=$(echo "scale=$scale; $u*$k2" | bc)
x=$(echo "scale=$scale; $u1/$k1" | bc)

info "($u * $k2) / $k1"
info "x ="
echo $x
