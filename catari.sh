#!/bin/bash -e

verbose=false
dasm_home='/home/wonka/Downloads/emulate/atari2600/dasm-2.20.11'
atari_include_dir="$dasm_home/machines/atari2600"
bin_dir='/home/wonka/Downloads/emulate/atari2600/roms'

if [[ ! "$1" == *-* ]]; then
	game="$1"
	shift
fi

do_help() {
	echo "compile atari game with dasm."
	echo ""
	echo "usage:"
	echo "$0 game-name"
	echo ""
	echo "- the file game-name.asm must exist in the directory the command is being executed on."
	echo "- files game-name.txt with list of symbols and game-name.bin will be created."
	echo "- game-name.bin will also be copied to $bin_dir"
}

debug() {
	if [ $verbose == true ]; then
		echo "$1"
	fi
}

require() {
	switch=--string
	if [[ "$1" == *-* ]]; then
		switch=$1
		shift
	fi
	
	value="$1"
	msg="$2"
	
	case $switch in
		--string|-s)
			if [ ! -n "$value" ]; then
				echo "$msg"
				exit 1
			fi
		;;
		--file|-f)
			if [ ! -f "$value" ]; then
				echo "Required file not found: '$value'"
				exit 1
			fi		
		;;
		--dir|-d)
			if [ ! -d "$value" ]; then
				echo "Required directory not found: '$value'"
				exit 1
			fi				
		;;
	esac
}

while test $# -gt 0
do
    case "$1" in
		--help|-h)
        	do_help
        	exit 0
      ;;
      --verbose|-v) 
        	verbose=true
      ;;
      --game|-g)
      	shift
      	game="$1"
      ;;
      --*) 
        	echo "bad option '$1'"
      ;;
    esac
    shift
done

require -f "$game.asm"

echo "$dasm_home/bin/dasm $game.asm -l$game.txt -f3 -v5 -I$atari_include_dir -o$game.bin"
$dasm_home/bin/dasm $game.asm -l$game.txt -f3 -v5 -I$atari_include_dir -o$game.bin
cp $game.bin $bin_dir

exit 0
