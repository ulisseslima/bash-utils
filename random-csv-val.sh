#!/bin/bash
# gets a random index from a csv string
# e.g.: $0 1,2,3,4 -> 2
# e.g.: $0 '1 ,2,3, 4' -> 2

source $(real require.sh)

csv_string="$1"
require csv_string

# Split the string into an array
IFS=',' read -ra arr <<< "$csv_string"

# Get a random index from the array
index=$((RANDOM % ${#arr[@]}))

# Print out the random value
echo "${arr[$index]}" | xargs
