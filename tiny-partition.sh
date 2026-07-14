#!/bin/bash -e
# creates a partition of the given size in the given file
# useful for testing "no space left on device" errors
MYSELF="$(readlink -f "$0")"
MYDIR="${MYSELF%/*}"
ME=$(basename $MYSELF)

source $(real require.sh)

size=10
path=/tmp/test_disk.img
directory=/mnt/tiny-space

while test $# -gt 0
do
    case "$1" in
        --path)
            shift
            path="$1"
        ;;
        --size)
            shift
            size="$1"
        ;;
        *)
            echo "unrecognized option: $1"
            exit 1377
        ;;
    esac
    shift
done

echo "# 1. Create a blank ${size}MB file to act as the virtual disk"
dd if=/dev/zero of="$path" bs=1M count="$size"

echo "# 2. Format the file with an ext4 filesystem (disable root reserved blocks)"
mkfs.ext4 -m 0 "$path"

echo "# 3. Create a mount target directory"
sudo mkdir -p "$directory"

echo "# 4. Mount the file as a loop device"
sudo mount -o loop "$path" "$directory"

echo "# 5. Grant read/write permissions so your app can access it"
sudo chmod 777 "$directory"

echo "# 6. Done! You can now use $directory as a tiny partition of $size MB"
read -p "Press enter to unmount and delete the partition file"

sudo umount "$directory"
sudo rm -f "$path"
sudo rmdir "$directory"

echo "# 7. Done! The tiny partition has been removed"
