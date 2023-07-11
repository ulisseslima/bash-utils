#!/bin/bash
# https://stackoverflow.com/questions/22322372/sox-doesnt-work-with-opus-audio-files

tmp_mp3="/tmp/$(basename $1).mp3"
opusdec --force-wav "$1" - | sox - "$tmp_mp3"

play "$tmp_mp3" && rm "$tmp_mp3"
