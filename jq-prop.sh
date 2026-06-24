#!/bin/bash
# prints a property value from the json in stdin

jq -r ".${1}"
