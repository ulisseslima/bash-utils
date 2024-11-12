#!/bin/bash

function urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

urldecode $(cat /dev/stdin)

