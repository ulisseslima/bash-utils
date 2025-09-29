#!/bin/bash

export JAVA_HOME=$JAVA24_HOME
if [[ -n "$1" ]]; then
    code $(real "$1")
else
    code
fi
