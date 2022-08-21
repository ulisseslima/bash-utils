#!/bin/bash
# removes decimal information

source $(real require.sh)

n="$1"
require -n n

echo "$n" | cut -d'.' -f1