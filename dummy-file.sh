#!/bin/bash -e

if [ "$1" == '--help' ]; then
  echo "creates a temporary file in /tmp with $1 MB in size."
  echo "example to create a temporay file with 50 MB:"
  echo "$0 50"
  echo "a file /tmp/dummy.50 will be created"
fi

mb=$1
bytes=$((1024*1024*mb))

dd if=/dev/zero of=/tmp/dummy.$mb bs=$bytes count=1
