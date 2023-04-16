#!/bin/bash
# https://stackoverflow.com/questions/7333232/how-to-concatenate-two-mp4-files-using-ffmpeg

ffmpeg -safe 0 -f concat -i <(find . -type f -name "*-video.mp4" -printf "file '$PWD/%p'\n" | sort) -c copy "concat.mp4"

