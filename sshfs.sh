#!/bin/bash -e
# mount a ssh host directory locally
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

user="$USER"
mountpoint='.'
pubk=$HOME/.ssh/id_rsa

echo "########################"
echo "sshfs connection utility"

while test $# -gt 0
do
    case "$1" in
        --list)
            df -h | grep '@'
            exit 0
        ;;
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
        --unmount|--un|--umount)
            shift
            dir="$1"

            echo "ummounting $dir ..."
            fusermount -u $dir
            exit 0
        ;;
        --public-key)
            shift
            pubk="$1"
        ;;
        *)
            echo "bad option: '$1'"
            exit 1
        ;;
    esac
    shift
done

if [[ ! -f $pubk ]]; then
    echo "generating public key..."
    ssh-keygen
fi

group=fuse
if [[ $(grep -c $group /etc/group || true) -lt 1 ]]; then
    echo "adding new group '$group' ..."
    sudo groupadd $group
fi

if [[ "$(groups)" != *$group* ]]; then
    echo "adding $USER to $group group..."
    $MYDIR/add-group.sh $group
fi

fusef=/etc/fuse.conf
allow_flag=user_allow_other
allow=$(grep -v '#' $fusef | grep -c $allow_flag || true)
if [[ $allow -lt 1 ]]; then
    echo "adding $allow_flag to $fusef ..."
    echo $allow_flag | sudo tee -a $fusef 
fi

[[ -z "$localpoint" ]] && localpoint="$HOME/$host/$(basename $mountpoint)"

echo "will mount $user@$host:$mountpoint at $localpoint, continue?"
read confirmation

echo "ummounting any old mounts..."
fusermount -u $localpoint || true
sudo rm -rf $localpoint
 
echo "creating local point: $localpoint"
sudo mkdir -p "$localpoint"
sudo chown -R $USER:$USER "$localpoint"

echo "testing local point..."
test -e $localpoint || mkdir --mode 700 $localpoint

echo "mounting remote point: $user@$host:$mountpoint"
#sshfs -o allow_other,default_permissions,IdentityFile=$pubk \
sshfs \
    -o allow_other \
    -o default_permissions \
    -o IdentityFile=$pubk \
    $user@$host:$mountpoint $localpoint -p 22

echo "testing:"
df -h | grep "$user@$host:$mountpoint"
ls -lt $localpoint | head -5

if [[ -d "$localpoint" ]]; then
    echo "browsing $localpoint ..."
    nautilus $localpoint
else
    echo "something went wrong creating $localpoint"
fi
