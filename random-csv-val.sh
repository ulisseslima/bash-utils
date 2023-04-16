#!/bin/bash

source $(real require.sh)

csv_string="$1"
require csv_string

# Split the string into an array
IFS=',' read -ra arr <<< "$csv_string"

# Get a random index from the array
index=$((RANDOM % ${#arr[@]}))

# Print out the random value
echo "${arr[$index]}"
