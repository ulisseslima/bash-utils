#!/bin/bash -e
# https://linuxize.com/post/how-to-install-and-configure-an-nfs-server-on-ubuntu-20-04/
# note: to be run on server side
# creates a share and exports it

fstab=/etc/fstab
exports=/etc/exports
root=/mnt
subnet='192.168.1.0/24'

sudo apt install nfs-kernel-server
sudo cat /proc/fs/nfsd/versions
# expect:
# -2 +3 +4 +4.1 +4.2

target="$1"
if [[ ! -d "$target" ]]; then
        echo "folder to export must exist: $target"
        exit 1
fi

share=$root/$target
echo "will export $target at $share - confirm?"
read confirmation

echo "mounting..."
if [[ ! -d "$share" ]]; then
        echo "share didn't exist. creating..."
        sudo mkdir -p $share
        sudo chown -R $USER:$USER $share
fi

sudo mount --bind $target $share
echo "$target   $share  none    bind    0       0" | sudo tee -a $fstab

echo "exporting..."
echo "$root         $subnet(rw,sync,no_subtree_check,crossmnt,fsid=0)" | sudo tee -a $exports
sudo exportfs -ar

echo "done. test:"
sudo exportfs -v
ls -lt $share | head -5

echo "adding firewall rule..."
sudo ufw allow from $subnet to any port nfs
