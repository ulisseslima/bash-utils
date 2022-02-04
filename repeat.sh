#!/bin/bash
# repeat the execution of a script n times with t threads
# each thread will execute the script n times

source $(real require.sh)

script="$1"
require script "script to execute"
shift

script=$(readlink -f $script)

times=2
threads=2

while test $# -gt 0
do
    case "$1" in
    --times|-n)
        shift 
        times=$1
    ;;
    --threads|-t)
        shift
        threads="$1"
    ;;
    -*) 
      echo "bad option '$1'"
    ;;
    esac
    shift
done

echo "will run $script $times times with $threads threads, confirm?"
read confirmation

for ((i=1;i<=$times;i++))
do
    for ((j=1;j<=$threads;j++))
    do
        nohup "$script" &
        pids[${i}]=$!
    done

    for pid in ${pids[*]}
    do
        echo "waiting $pid ..."
        wait $pid
    done
done

echo done