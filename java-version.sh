#!/bin/bash

javabin=${1:-java}

$javabin -version 2>&1 | head -1 | cut -d'"' -f2 | sed '0,/^1\./s///' | cut -d'.' -f1
