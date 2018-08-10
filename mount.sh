#!/bin/bash -e
do_check_root() {
        if [[ $EUID -ne 0 ]]; then
                echo "this script must be run as root" 1>&2
                exit 1
        fi
}

do_check_root

do_find_part_uuid() {
	partition=$1
	blkid | grep $partition | cut -d'"' -f2
}

partition="$1"
user="$SUDO_USER"
dir="$HOME/$partition"
type=ext4

while test $# -gt 0
do
	case "$1" in
		####
		# Define a partição a ser montada
		--partition|-p)
			shift
			partition="$1"
		;;
		--user|-u)
			shift
			user="$1"
		;;
		--partition|-p)
			shift
			partition="$1"
		;;
		--dir|-d)
			shift
			dir="$1"
		;;
		--type|-t)
			shift
			type="$1"
		;;
		--*)
			echo "opção não reconhecida: $1"
			exit 1
		;;
	esac
	shift
done

if [ ! -n "$partition" ]; then
	echo "no partition specified. specify it as the first argument, or with --partition"
	exit 1
fi

echo "mounting partition $partition on $dir as $type, owner will be $user"
echo "press <enter> to confirm"
read enter

mkdir -p "$dir"

uuid=$(do_find_part_uuid $partition)
if [ ! -n "$uuid" ]; then
	echo "couldn't find uuid for $partition. does it exist?"
	lsblk
	exit 1
fi

echo "" >> /etc/fstab
echo "# $(date) - $(readlink -f $0) - ${user}@${partition}:" >> /etc/fstab
echo "UUID=$uuid	$dir	$type	defaults	0	2" >> /etc/fstab

tail -2 /etc/fstab

mount -a

chown -R $user:$user $dir
