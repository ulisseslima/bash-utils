#!/bin/bash
# splits a file into various segments with the specified seconds

source $(real require.sh)

input="$1"
require -f input "input file"
shift

odir=$(dirname "$input")
cd "$odir"

extension=$(basename "$input" | rev | cut -d'.' -f1 | rev)

seconds=$1
require seconds "segment size"

if [[ $seconds == half ]]; then
	seconds=$(op.sh $(ffmpeg-info.sh $input duration)/2)
	>&2 echo "half segment: $seconds seconds"
	require seconds "half duration calculation"
fi

ffmpeg -i "$input" -f segment -segment_time $seconds -reset_timestamps 1 -c copy "${input}-segment-%03d.$extension"
