#!/bin/bash

ARG1=$1
ARG2="default"

if [[ -n "$2" ]]; then
  ARG2=$2
fi

echo $ARG2
