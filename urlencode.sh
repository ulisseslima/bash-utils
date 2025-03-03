#!/bin/bash

cat /dev/stdin | jq -sRr @uri | sed -e 's/\(%0A\)*$//g'

