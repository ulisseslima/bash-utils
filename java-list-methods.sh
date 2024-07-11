#!/bin/bash
# takes a compiled java class and lists its methods
source $(real require.sh)

# Check if a class file was provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 path/to/CompiledClass.class"
    exit 1
fi

class="$1"
require -f class 

# Use javap to list the method signatures of the class
javap -s "$class" | grep -E '^[ ]*(public|protected|private|static|\[)'
