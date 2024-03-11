#!/bin/bash
# converts string clock format (e.g.: 15:45:11.555) to hours in float
# TODO needs adjustments to work properly
source $(real require.sh)

# Function to convert float hours to clock format
float_hours_to_time() {
    local float_hours=$1
    local hours minutes seconds

    # Extract hours
    hours=$(printf "%.0f" "$float_hours")

    # Extract remaining minutes
    float_minutes=$(bc <<< "scale=10; ($float_hours - $hours) * 60")
    minutes=$(printf "%.0f" "$float_minutes")

    # Extract remaining seconds
    float_seconds=$(bc <<< "scale=10; ($float_minutes - $minutes) * 60")
    seconds=$(printf "%.0f" "$float_seconds")

    # Format the time string
    printf "%02d:%02d:%02d\n" "$hours" "$minutes" "$seconds"
}

# Example usage:
float_hours=15.753
require float_hours 'arg1: hours in float'

clock_format=$(float_hours_to_time "$float_hours")
echo "$clock_format"
