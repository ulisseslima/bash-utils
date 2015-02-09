#!/bin/bash -e

# follows a log file, filtering by grep

log_file="$1"
tmp_dir=`mktemp -d`

nohup tail -f "$log_file" > "$tmp_dir/follow.sh.txt"

#TODO


