#!/bin/bash
# tests a specific class

source $(real require.sh)

classname=$1
require classname "arg1 should be test class name (no package)"
shift

mvn clean test -Dtest="$classname" "$@"
