#!/bin/bash
# https://superuser.com/questions/138331/using-ffmpeg-to-cut-up-video
# trims the desired amount of seconds from the start/end/both
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"

source $(real require.sh)

input="$1"
require -f input
shift

start=0
end=0

in_dir=$(dirname "$input")
in_name=$(basename "$input" | rev | cut -d'.' -f2- | rev)

out="${in_dir}/${in_name}-trimmed.mp4"

params="-v 24"

while test $# -gt 0
do
    case "$1" in
        --start|-a)
            shift
	        start="$1"
        ;;
        --end|-b)
            shift
	        end="$1"
        ;;
        --both)
            shift
            start="$1"
            end="$1"
        ;;
        --quiet|-q)
            params="-v 16"
        ;;
        --debug)
            params="-v 56"
        ;;
        --out|-o)
            shift
            out="$1"
        ;;
        -*)
            echo "unrecognized option: $1"
            exit 1377
        ;;
    esac
    shift
done

original_duration=$(ffmpeg-info.sh "$input" duration)
adjusted_duration=$(op.sh ${original_duration}-${start}-${end})

ffmpeg $params -ss $start -i "${input}" -t $adjusted_duration -map 0 -c copy "${out}"
echo ${out}
