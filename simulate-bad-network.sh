#!/bin/bash

switch=${1:-add}
interface=${2:-eth0}
delay=${3:-50}
loss=${4:-1}

echo "interface ${interface}, ${switch}: network delay of $delay ms with ${loss}% packet loss"

tc qdisc $switch dev $interface root netem delay ${delay}ms loss ${loss}%
