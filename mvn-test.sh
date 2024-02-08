#!/bin/bash

classname=$1
mvn clean test -Dtest="$classname"
