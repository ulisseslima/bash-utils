#!/bin/bash
# mount a ssh host directory locally

host="$1"
user=${2:-$USER}
mp=${3:-.}

echo "will mount $user@$host:$mp at ~/$host, continue?"
read confirmation

test -e ~/$host || mkdir --mode 700 ~/$host
sshfs $user@$host:$mp ~/$host -p 22

nautilus ~/$host

# ummount:
# fusermount -u ~/$host

