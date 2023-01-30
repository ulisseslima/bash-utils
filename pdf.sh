#!/bin/bash
# pdf from text (stdin)

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

while test $# -gt 0
do
    case "$1" in
    --help|-h)
	echo "creates a PDF from text."
        echo "usage:"
        echo "echo text | pdf.sh"
      exit 0
    ;;
    --verbose|-v)
      verbose=true
    ;;
    --landscape)
      options="$options --landscape"
    ;;
    -*)
      echo "bad option '$1'"
    ;;
    esac
    shift
done

now=$(date +'%Y-%m-%d_%H-%M-%S')
fname="pdf-${now}"

require -f $(which enscript) lib
require -f $(which ps2pdf) lib

enscript -v -X latin1 $options -p "${fname}.ps"
ps2pdf "${fname}.ps"

rm "${fname}.ps"

out="$1"
if [ -n "$out" ]; then
	mv "${fname}.pdf" "$out"
fi
