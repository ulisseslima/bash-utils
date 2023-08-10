#!/bin/bash -e
# adds a group to current user

group="$1"
user=${2:-$USER}

if [ $(getent group $group) ]; then
    getent group $group
else
    echo "group '$group' does not exist. create?"
    read confirmation
    groupadd $group
fi

echo "adding '$user' to '$group'..."
sudo usermod -aG $group $user

echo "you need to login again:"
echo "su $user -"

echo "current groups:"
groups
