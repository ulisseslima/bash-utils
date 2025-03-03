#!/bin/bash
# returns internet ip address info

curl https://api.myip.com | jq -r '.ip'
hostname -I | awk '{print $1}'
