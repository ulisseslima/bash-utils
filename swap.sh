#!/bin/bash
# create swap file
# TODO check if already exists
# https://askubuntu.com/questions/904372/swap-partition-vs-swap-file

gb=${1:-16}
swpf=${2:-/swapfile}

echo "will create a ${gb}gb swap file on ${swpf}, continue?"
read confirmation

echo "turning swap off ..."
sudo swapoff -a

echo "creating swap file at $swpf ..."
sudo dd if=/dev/zero of=$swpf bs=1G count=$gb

echo "adjusting permissions ..."
sudo chmod 600 $swpf

echo "formatting ..."
sudo mkswap $swpf

echo "turning swap on ..."
sudo swapon $swpf

echo "result:"
sudo swapon --show
