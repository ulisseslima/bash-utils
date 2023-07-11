#!/bin/bash

destination="${2:-${1}.ogg}"
ffmpeg <&1- -v 16 -i "$1" -c:a libopus -b:a 128K "${destination}"
