#!/bin/sh

debug_dir=/usr/debug

toggle() {
	project=$1
	option=$2
	if [ -f "$debug_dir/$project-enabled" ]; then
		sudo mv "$debug_dir/$project-enabled" "$debug_dir/$project-disabled"
		echo "$debug_dir/$project-disabled"
	else
		sudo rm -f "$debug_dir/$project-disabled"
		sudo touch "$debug_dir/$project-enabled"
		echo "$debug_dir/$project-enabled"
	fi
}

case "$1" in
  --help)
	echo "Usage: $0 project-name {|on|off|toggle}"
	exit 1	
	;;
  *)
	toggle $1 $2	
	;;
esac
