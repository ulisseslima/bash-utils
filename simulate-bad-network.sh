#!/bin/bash

log=$HOME/logs/tc_qdisc-history.log
mkdir -p `dirname $log`

switch=${1:-add}
interface=${2:-eth0}
delay=${3:-1000}
loss=${4:-1}

echo "interface ${interface}, ${switch}: network delay of $delay ms with ${loss}% packet loss"

c="tc qdisc $switch dev $interface root netem delay ${delay}ms loss ${loss}%"
echo "$c"
echo "$c" >> $log
$c
