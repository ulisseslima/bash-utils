#!/bin/bash

ps aux | grep java | inline-java.sh 'println(stdin.replace(" ","\n"));' | grep dataSource | uniq | rev | cut -d"/" -f1 | rev
