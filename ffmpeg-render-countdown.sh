#!/bin/bash
# adds a countdown timer to a video
# https://superuser.com/questions/1826617/adding-timer-to-video-using-ffmpeg
# https://stackoverflow.com/questions/47543426/ffmpeg-embed-current-time-in-milliseconds-into-video
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

source $(real require.sh)

input=$1
require -f input "original video"
shift

fontsize=32
font=Roboto
fontcolor=white
bordercolor=white
borderw=3

coords_x=20
coords_y='(H-th)/2'

# overlay_x=0
# overlay_y='(main_h-overlay_h)/(main_h-overlay_h)' top
overlay_x='(main_w-overlay_w)'
overlay_y=H-h

stamp_res=600x100
label="" #optional text shown to the side of the timer, e.g.: "Time left \:"

while test $# -gt 0
do
    case "$1" in
	--out|-o)
		shift
		out="$1"
	;;
  --label)
		shift
		label="$1"
	;;
  --offset-y)
    shift
    offset_y="$1"
  ;;
  --offset-x)
    shift
    offset_x="$1"
  ;;
  --font-size)
    shift
    fontsize=$1
  ;;
  -*)
    >&2 echo "$ME - bad option '$1'"
    exit 1
  ;;
  esac
  shift
done

require out

duration=$(ffmpeg-info.sh "$input" duration)
require duration

ffmpeg <&1- -y -v 16 -f lavfi -i "color=color=#00000000@0:size=$stamp_res:duration=$duration:r=30,format=rgba,settb=AVTB,drawtext=text='${label}%{pts\:gmtime\:0\:%#M\\\\\:%S}':fontsize=$fontsize:fontcolor=$fontcolor:bordercolor=$bordercolor:borderw=$borderw:x=$coords_x:y=$coords_y:font=$font"\
 -i $input\
 -filter_complex "[0]reverse[timer];[1][timer]overlay=x=${overlay_x}${offset_x}:y=${overlay_y}${offset_y}:enable='between(t,0,$duration-1)'"\
 -y -c:v libx264 -c:a copy "$out"
