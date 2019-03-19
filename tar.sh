#!/bin/bash

folder="$1"

if [ ! -d "$folder" ]; then
	echo "first arg must be an existing folder"
	echo ""
	echo "$(basename $0): tar with progress bar"
	exit 1
fi

tarname=$(basename "$folder").tar.gz

echo "tarring '$folder' as $tarname"
tar cf - "$folder" -P | pv -s $(du -sb "$folder" | awk '{print $1}') | gzip > "$tarname"

du -sh $tarname
