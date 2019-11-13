#!/bin/bash
# depends on: translate-shell

word="$1"
lang="${2:-es}"
trans ":$lang" --brief "$word"
