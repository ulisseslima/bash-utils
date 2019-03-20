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
	        echo "not found: '$1'. installing..."
		sudo apt-get install enscript ghostscript
        fi
      ;;
    esac
}

now=$(date +'%Y-%m-%d_%H-%M-%S')
fname="pdf-${now}"

require -f $(which enscript)
require -f $(which ps2pdf)

enscript -p "${fname}.ps" /dev/stdin
ps2pdf "${fname}.ps"

rm "${fname}.ps"

out="$1"
if [ -n "$out" ]; then
	echo "moving ${fname}.pdf to $out"
	mv "${fname}.pdf" "$out"
fi
