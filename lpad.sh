#!/bin/bash

n=$1
pads=${2:-2}
printf "%0${pads}d\n" $n
