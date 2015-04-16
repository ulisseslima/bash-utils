#!/bin/bash -e

echo "replacing '$1' with '$2'"
sed -i 's/$1/$2/g' $3
