#!/bin/bash

export id=`xinput list | grep -i touchpad | awk -F"=" '{ print $2 }' | awk '{ print $1 }' | grep -v 12`
xinput list-props "${id}" | grep "Synaptics Scrolling Distance" | sed 's/[^0-9 \t-]//g' | while read a b c;
do
 echo af
 echo "${a} ${b} $((${c}*-1))";
 echo xinput set-prop "${id}" "${a}" "${b}" "$((${c}*-1))"
done
