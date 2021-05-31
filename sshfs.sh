#!/bin/bash -e
# mount a ssh host directory locally

user="$USER"
mountpoint='.'

while test $# -gt 0
do
    case "$1" in
        --host|-h)
            shift
            host="$1"
        ;;
        --user|-u)
            shift
            user="$1"
        ;;
        --mountpoint|-m)
            shift
            mountpoint="$1"
        ;;
        --localpoint|-l)
            shift
            localpoint="$1"
        ;;
        --ummount)
            shift
            dir="$1"
            fusermount -u $dir
        ;;
        *)
            echo "bad option: '$1'"
            exit 1
        ;;
    esac
    shift
done

[[ -z "$localpoint" ]] && localpoint="$HOME/$host/$(basename $mountpoint)"

echo "will mount $user@$host:$mountpoint at $localpoint, continue?"
read confirmation

if [[ ! -d "$localpoint" ]]; then
    echo "creating local point: $localpoint"
    sudo mkdir -p "$localpoint"
    sudo chown -R $USER:$USER "$localpoint"
fi

echo "testing local point..."
test -e $localpoint || mkdir --mode 700 $localpoint

echo "mounting remote point: $user@$host:$mountpoint"
sshfs $user@$host:$mountpoint $localpoint -p 22

echo "testing:"
df -h | grep "$user@$host:$mountpoint"

if [[ -d "$localpoint" ]]; then
    echo "browsing $localpoint ..."
    nautilus $localpoint
else
    echo "something went wrong creating $localpoint"
fi
