#!/bin/bash

echo "Host *
  ServerAliveInterval 30" > ~/.ssh/config

chmod 600 ~/.ssh/config
