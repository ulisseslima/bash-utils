#!/bin/bash

source $(real require.sh)

job_id=$1
require job_id

full=false

while test $# -gt 0
do
    case "$1" in
        --full)
            full=true
        ;;
        -*)
            echo "unrecognized option: $1"
            exit 1377
        ;;
    esac
    shift
done

if [[ $full == true ]]; then
	content=$(at -c $job_id | tail -2 | head -1)
	script=$(echo "$content" | cut -d' ' -f1)
	others=$(echo "$content" | cut -d' ' -f2-)
	echo "$(basename $script) $others"
else
	content=$(at -c $job_id | tail -2 | head -1)
	script=$(echo "$content" | cut -d' ' -f1)
	others=$(echo "$content" | cut -d' ' -f2-)
	echo "$(basename $script) $others"
fi
