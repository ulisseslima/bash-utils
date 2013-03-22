#!/bin/bash

CAS=$1

if [ "$CAS" == "what" ]; then
  echo "exiting"
  exit 1
fi

echo "didn't exit"
