#!/bin/bash
# accept data through a port

port="$1"
sudo iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport $port -j ACCEPT
