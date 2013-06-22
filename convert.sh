#!/bin/bash

convert_to_mp3() {
	f="$1"
	flac -cd "$f" | lame -b 320 - "${f%.*}".mp3
}

convert_all_to_mp3() {
	for f in *.flac 
	do 
		convert_to_mp3 "$f"
	done
}

while test $# -gt 0
do
    case "$1" in
		--to-mp3) 
			shift
        	convert_to_mp3 "$1"
      ;;
      --all-to-mp3)
        	convert_all_to_mp3
      ;;
      --*) 
        	echo "bad option $1"
        	exit 1
      ;;      
    esac
    shift
done

exit 0
