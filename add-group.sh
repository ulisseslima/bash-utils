#!/bin/bash
# adds a group to current user

group="$1"
user=${2:-$USER}

echo "adding '$user' to '$group'..."
sudo usermod -aG $group $user

echo "you need to login again:"
echo "su $user -"

echo "current groups:"
groups
