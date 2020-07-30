#!/bin/bash
# adds a group to current user

user=$USER
group="$1"

echo "adding '$user' to '$group'..."
sudo usermod -aG $group $user

echo "you need to login again:"
echo "su $user -"

echo "current groups:"
groups
