#!/bin/bash

GW="$(sudo /sbin/route -n | awk '{if ($1=="0.0.0.0") {print $2} ; q}')"
sudo /sbin/route del default gw "$GW"
echo "$GW" >~/my_tmp_file

echo "press any key to turn internet access back on..."
read
echo "turning internet access back on..."

sudo /sbin/route add default gw "$(cat ~/my_tmp_file)"

