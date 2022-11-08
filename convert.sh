#!/bin/bash -e

source $(real require.sh)
source $(real log.sh)

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

convert_to_utf8() {
	f="$1"
	destination="${2:-$f}"
	
	require.sh -f "$f"

	encoding=$(check_encoding "$f")
	if [[ "$encoding" != UTF-8 && "${encoding}" != *ASCII* && "$encoding" != BINARY ]]; then
		iconv -f $encoding -t UTF-8//TRANSLIT "$f" -o /tmp/f
		mv /tmp/f $destination
	elif [[ "$f" != "$destination" ]]; then
		mv "$f" "$destination"
	fi

	echo $encoding
}

check_encoding() {
	f="$1"
	require.sh -f "$f"

	encoding=$(file -i "$f" | cut -d'=' -f2)
	echo ${encoding^^}
}

# export only keyframes so it's not a huge output
export_keyframes() {
	f="$1"
	require.sh -f "$f"

	mime=$(file "$f")
	if [[ "$mime" != *MP4* ]]; then
		err "only MP4 supported"
		exit 1
	fi

	ffmpeg -skip_frame nokey -i "$f" -vsync 0 -f image2 frame-%02d.jpg
}

while test $# -gt 0
do
    case "$1" in
		--to-mp3) 
			shift
        	convert_to_mp3 "$1"
		;;
		--to-utf-8) 
			shift
        	convert_to_utf8 "$1" "$2"
		;;
		--check-encoding) 
			shift
        	check_encoding "$1"
		;;
		--all-to-mp3)
			convert_all_to_mp3
		;;
		--keyframes)
			shift
			export_keyframes "$1"
		;;
		--*) 
			echo "bad option $1"
			exit 1
		;;      
    esac
    shift
done

exit 0
