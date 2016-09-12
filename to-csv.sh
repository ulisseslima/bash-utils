#!/bin/bash

# $1 is the field
# vORS defines the separator
# sed replaces the trailing separator with a new line
awk -vORS=';' '{ print $1 }' ~/dev/mail/outbox/pending | sed 's/;$/\n/'
