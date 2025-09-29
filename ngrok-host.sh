#!/bin/bash
host=$(curl --silent http://127.0.0.1:4040/api/tunnels | jq -r '.tunnels[].public_url')
echo $host | ctrlc.sh -v
