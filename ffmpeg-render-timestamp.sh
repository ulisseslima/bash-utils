#!/bin/bash
# adds a timestamp of the current time to a video
# https://superuser.com/questions/1826617/adding-timer-to-video-using-ffmpeg
# https://stackoverflow.com/questions/47543426/ffmpeg-embed-current-time-in-milliseconds-into-video
# include the current timestamp in the video out

source $(real require.sh)

input=$1
require -f input "input file"
shift

while test $# -gt 0
do
    case "$1" in
	--out|-o)
		shift
		out="$1"
	;;
    -*)
      err "bad option '$1'"
      exit 1
    ;;
    esac
    shift
done

require -f out

ffmpeg -i $input -vf "drawtext='text=%{localtime\:%X.%N}:font=Roboto:fontsize=32:fontcolor=white'" "$out"

# older alternative:
# ffmpeg -i $input -vf "settb=AVTB,setpts='trunc(PTS/1K)*1K+st(1,trunc(RTCTIME/1K))-1K*trunc(ld(1)/1K)',drawtext=text='%{localtime}.%{eif\:1M*t-1K*trunc(t*1K)\:d}':fontcolor=white" output.mp4 

# ffmpeg -i $input -vf "drawtext='text=%{pts\:gmtime\:0\:%M\\\\\:%s}':font=Roboto:fontsize=32:fontcolor=white'" output3.mp4

