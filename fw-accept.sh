#!/bin/bash
# accept data through a port

source $(real require.sh)

port="$1"
require port

sudo iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport $port -j ACCEPT
