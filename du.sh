#!/bin/bash
# summarize size of files found with pattern

start_dir=${}

find . -type f -name 'batik*' -exec du -ch {} + | grep total
