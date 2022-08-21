#!/bin/bash

p=$(real "$1")
editor=${2:-nano}

echo "$editor $p"
ls -la "$p"
$editor "$p"
