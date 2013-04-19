#!/bin/bash -e

cat ~/.bash_history | grep "$2" | tail -$1
