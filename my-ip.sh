#!/bin/bash
# returns internet ip address info

echo "local=$(hostname -I | awk '{print $1}')"
echo "global=$(curl https://api.myip.com | jq -r '.ip')"
