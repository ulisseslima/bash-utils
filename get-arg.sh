#!/bin/bash
# get a specific named arg from an args list
key=$1
shift

for ((i=1; i <= $#; i++)); do
        # Check if the current argument is the key we're looking for
        if [ "${!i}" == "$key" ]; then
            # Get the next argument (the value)
            next_arg_index=$((i + 1))
            echo "${!next_arg_index}"
            exit 0
        fi
done
