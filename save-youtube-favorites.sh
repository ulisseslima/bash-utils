#!/bin/bash

###
# To be used in conjunction with a IFTTT recipe.
#
# Pre-requisites: ffmpeg, youtube-dl, dropbox
#
# IFTTT recipe: If new liked video (YouTube), then append to a text file (liked-videos.txt) in Dropbox
# * File name: liked-videos
# * Content: {{Url}}
# * Dropbox folder path: ifttt/YouTube
#
########

fhome="$HOME/Dropbox/ifttt/YouTube"
fname=liked-videos.txt
flog="$fhome/last.run.txt"

log() {
    echo "$1"
    echo "$1" >> "$flog"
}

echo `date` > "$fhome/last.run.txt"

if [ -f "$fhome/$fname" ]
then
    cd "$fhome"
    youtube-dl -x -a "$fname"
    mv "$fname" "$fname - `date`.bk"
else
    log "no videos to download"
fi

cd "$fhome"

for song in "$fhome/"*.m4a
do
    if [[ ! -e "$song" ]]; then continue; fi

    artist=$(basename "$song" | cut -d '-' -f1 | awk '{$1=$1;print}')
    track=$(basename "$song" | cut -d '-' -f2 | awk '{$1=$1;print}')

    log "moving '$track' by '$artist'"
    mkdir -p "$artist"
    mv "$song" "$artist"
done
