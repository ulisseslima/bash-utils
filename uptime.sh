#!/bin/bash

uptime=`uptime`
upt=`echo $uptime | grep -ohe 'up .*user*' | awk '{gsub ( "user*","" ); print $0 }' | sed 's/,//g' | sed -r 's/(\S+\s+){1}//' | awk '{$NF=""}1'`
usrs=`echo $uptime | grep -ohe '[0-9.*] user[s,]'| sed 's/,//g'`
ldt=`echo $uptime | grep -ohe 'load average[s:][: ].*' | sed 's/,//g' | awk '{ print $3" "$4" "$5"," }'`

echo $upt, $usrs, $ldt
