#!/bin/bash

# Define the range
MIN=${1:-0.98}
MAX=${2:-1.10}

# Generate a random float
RANDOM_FLOAT=$(awk -v min=$MIN -v max=$MAX 'BEGIN { srand(); print min + (rand() * (max - min)) }')

echo "$RANDOM_FLOAT"
