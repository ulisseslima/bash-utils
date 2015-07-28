#!/bin/bash

###
#
# To be used in conjunction with a IFTTT recipe.
#
# Pre-requisites: ffmpeg, youtube-dl, dropbox
#
# IFTTT recipe: If new liked video (YouTube), then append to a text file in Dropbox
# * File name: liked-videos
# * Content: {{Url}}
# * Dropbox folder path: ifttt/YouTube
#
# Automation: just drop this script into /etc/cron.daily or /etc/cron.hourly or whatever
########

fhome="$HOME/Dropbox/ifttt/YouTube"
fname=liked-videos.txt

if [ -f "$fhome/$fname" ]
then
    cd "$fhome"
    youtube-dl -x -a "$fname"
    rm "$fname"
fi

