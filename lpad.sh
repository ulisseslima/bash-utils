#!/bin/bash
# pads a number $1 with $2 zeroes from the left
n=$1
pads=${2:-2}
printf "%0${pads}d\n" $n
