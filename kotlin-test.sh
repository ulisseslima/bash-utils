#!/bin/bash

class="$1"
java="${2:-8}"

jhome="JAVA${java}_HOME"

export JAVA_HOME=${!jhome}
echo "java: $JAVA_HOME"

mvn3 clean test -Dtest="$class"
