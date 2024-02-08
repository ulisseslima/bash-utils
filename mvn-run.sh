#!/bin/bash

# full name with package
classname=$1

mvn exec:java -Dexec.mainClass=$classname
