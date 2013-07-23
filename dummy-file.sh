#!/bin/bash -e

if [ "$1" == '--help' ]; then
  echo "creates a temporary file in /tmp with $1 MB in size."
  echo ""
  echo "example to create a temporay file with 50 MB:"
  echo "$0 50"
  echo "a file /tmp/dummy.50 will be created"
  echo ""
  echo "to free all the space created:"
  echo "$0 --clear"
  exit 0
fi

if [ "$1" == '--clear' ]; then
  echo "reclaiming space..."
  rm /tmp/dummy.*
  exit 0
fi

mb=$1
bytes=$((1024*1024*mb))

dd if=/dev/zero of=/tmp/dummy.$mb bs=$bytes count=1
