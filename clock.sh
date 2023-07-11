#!/bin/bash
# receives an amount of seconds and returns a string representation in mm:ss
total_seconds=$(echo $1 | cut -d'.' -f1)

# Calculate minutes and seconds
minutes=$(( total_seconds / 60 ))
seconds=$(( total_seconds % 60 ))

#minutes=$(op.sh $total_seconds/60)
#seconds=$(op.sh $total_seconds%60)

# Format the time string
time_string="${minutes}:$(lpad.sh ${seconds})"

echo "$time_string"
