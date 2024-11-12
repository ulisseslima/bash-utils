#!/bin/bash
# shows ram usage grouped by process name
top -b -n 1 | rev | tr -s ' ' | awk '{print $3, $1}' | rev | tr ' ' '|' | group.sh | awk -v FS='|' '{print $2, $1}' | sort -n | awk '{print $2, $1}' | grep -v ' 0'

free -m
