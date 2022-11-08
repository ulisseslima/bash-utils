#!/bin/bash
# depends on sudo apt-get install trash-cli -y

item="$1"
trash-put "$item"

trash-list | grep "$item"
