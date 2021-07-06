#!/bin/bash -e
# npm i -g ngrok

port="${1:-8080}"
ngrok http $port
