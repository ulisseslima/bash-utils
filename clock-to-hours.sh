#!/bin/bash
# converts string clock format (e.g.: 15:45:11.555) to hours in float

source $(real require.sh)

time_to_float_hours() {
    local time_str=$1
    local hours minutes seconds millis total_hours

    # Extract hours, minutes, secs, and millis from the time string
    IFS=':' read -r hours minutes seconds <<< "$time_str"
    millis=$(echo "$seconds" | cut -d'.' -f2)
    secs=$(echo "$seconds" | cut -d'.' -f1)
	>&2 echo "b: $hours $minutes $secs $millis"

    # Calculate total hours
    #total_hours=$(bc <<< "scale=3; $hours + ($minutes / 60) + ($secs / 3600) + ($millis / 3600000)")
    total_hours=$(echo "scale=3; ${hours} + (${minutes} / 60) + (${secs} / 3600) + (${millis} / 3600000)" | bc)

    echo "$total_hours"
}

time_str="$1"
require time_str 'arg1: time in clock format. e.g: 15:45:11.555'

float_hours=$(time_to_float_hours "$time_str")
echo "$float_hours"
