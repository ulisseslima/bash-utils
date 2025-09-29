#!/bin/bash
# show open java ports

source $(real require.sh)

require --app net-tools

sudo netstat -tulpn | grep java
