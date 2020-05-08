#!/usr/bin/python -tt
# coding=utf-8

###
# transforms a json array in key/value pairs, separated by = (can be changed by arg 2)
##

import sys, json
j = json.load(sys.stdin)
key = sys.argv[1]
val = sys.argv[2]
separator = "="
if len(sys.argv) > 3: separator = sys.argv[3]

for item in j:
    print("%s%s%s" % (item[key], separator, item[val]))
    #print("%s%s%s" % (item[key], separator, item[val]))