#!/bin/bash -e
# assert an address is up. if it isn't, exit with non zero status
curl -sSf "$address" > /dev/null
