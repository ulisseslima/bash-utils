#!/bin/bash
# grant default permissions to the directory based on the selected group

installed=$(which setfacl)
if [[ ! -f "$installed" ]]; then
	echo "installing facl ..."
	sudo apt install -y acl
fi

group="$1"
if [[ ! -n "$group" ]]; then
	echo "arg 1 is the group name"
	exit 1
fi

dir=$(readlink -f .)

echo "change default permissions on '$dir' to group '$group'?"
read confirmation

if grep -q $group /etc/group
then
	echo "group ok"
else
        echo "creating group $group ..."
	sudo groupadd $group
fi

if [[ "$(groups $USER | grep -c $group)" -lt 1 ]]; then
	echo "adding $USER to $group ..."
	sudo usermod -aG $group $USER
fi

echo "giving ownership to $group ..."
sudo chown -R :$group $dir

echo "setting default permissions ..."
# set gid:
chmod g+s $dir
# set group to rwx default:
setfacl -d -m g::rwx $dir
# set other:
setfacl -d -m o::rx $dir

echo "check if it worked:"
getfacl $dir
