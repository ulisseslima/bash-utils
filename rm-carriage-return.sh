#!/bin/bash
# removes carriage return characters. useful for fixing files created in windows

f=$1
sed -i -e 's/\r$//' $f
