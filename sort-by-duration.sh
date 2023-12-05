#!/bin/bash

source $(real require.sh)

start_dir=${1:-$PWD}
pattern="$2"

require pattern "file pattern"

result=/tmp/result
for f in $(find "$start_dir" -name "$pattern")
do
    echo "$(ffmpeg-info.sh "$f" --duration | lpad.sh _5) $(readlink -f $f)" >> $result
done

cat $result | sort -n
rm $result