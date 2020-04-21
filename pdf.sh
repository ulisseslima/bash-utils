#!/bin/bash

require() {
    switch='-s'
    if [[ "$1" == *'-'* ]]; then
        switch=$1
        shift
    fi

    case $switch in
      --file|-f)
        if [ ! -f "$1" ]; then
	        echo "required libs not found. installing..."
		sudo apt-get install enscript ghostscript
        fi
      ;;
    esac
}

if [[ "$1" == *-h* ]]; then
	echo "creates a PDF from text."
	echo "usage: "
	echo "echo text | pdf.sh"
fi

now=$(date +'%Y-%m-%d_%H-%M-%S')
fname="pdf-${now}"

require -f $(which enscript) lib
require -f $(which ps2pdf) lib

enscript -p "${fname}.ps"
ps2pdf "${fname}.ps"

rm "${fname}.ps"

out="$1"
if [ -n "$out" ]; then
	mv "${fname}.pdf" "$out"
fi
