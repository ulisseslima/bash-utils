#!/bin/bash
# https://www.kernel.org/doc/html/latest/admin-guide/sysrq.html

table="
2='0x2 - enable control of console logging level'
4='0x4 - enable control of keyboard (SAK, unraw)'
8='0x8 - enable debugging dumps of processes etc.'
16='0x10 - enable sync command'
32='0x20 - enable remount read-only'
64='0x40 - enable signalling of processes (term, kill, oom-kill)'
128='0x80 - allow reboot/poweroff'
256='0x100 - allow nicing of all RT tasks'
"

n=$(cat /proc/sys/kernel/sysrq)
echo "current setting: $n"

r=$(breakpow2.sh $n)
r=$(echo "$r" | tr -d '[' | tr -d ']')

while read pow
do
	echo "$table" | grep $pow
done < <(echo "$r" | tr ',' '\n' | tr -s ' ')
