#!/bin/bash

find . -type f -exec du -a {} + | sort -n -r
