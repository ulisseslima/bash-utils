#!/bin/bash
# https://thewolfsound.com/how-to-auto-tune-your-voice-with-python/
# https://github.com/JanWilczek/python-auto-tune/blob/main/auto_tune.py

source $(real require.sh)

autotune=$(real autotune.py)
require -f autotune "python script"

audio="$1"
require -f audio

if [[ $(file "$audio") != *WAVE* ]]; then
	converted="${audio}.wav"
	ffmpeg -i "$audio" "$converted"
	audio="$converted"
fi

echo "autotuning..."
time python3 "$autotune" "$audio" -c scale --scale E:min &

PID=$!
i=1
sp="/-\|"
echo -n ' '
while [ -d /proc/$PID ]
do
  printf "\b${sp:i++%${#sp}:1}"
  sleep .1
done

ls *_pitch_corrected*
