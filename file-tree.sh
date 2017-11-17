#!/bin/bash -e
mydir=$(dirname $0)
myname=$(basename $0 | cut -d'.' -f1)

do_help() {
  if [ "$1" == '--help' ]; then
    echo "creates a file tree with the specified depth and populates it with files until there are so many that ls will take more than the specified time limit to respond."
    echo ""
    echo "example:"
    echo "$0 --start-dir /home/tmp/file-tree --depth 3 --time-limit 5 --workers 2"
    echo ""
    echo "(time limit is in seconds)"
    exit 0
  fi
}

log() {
        echo "`date` - $0 - $1"
}

while test $# -gt 0
do
  case "$1" in
    --help|-h)
      do_help
      exit 0
    ;;
    --start-dir|-d)
      shift
      start_dir="$1"
    ;;
    --depth)
      shift
      depth=$1
    ;;
    --time-limit|-t)
      shift
      time_limit=$1
    ;;
    --workers|-w)
      shift
      workers=$1
    ;;
    -*) echo "unrecognized option $1"
      exit 1
    ;;
  esac
  shift
done

log "creating file tree on $start_dir"
mkdir -p "$start_dir"

log "starting $workers worker threads..."
pids=
for (( i=0; i<$workers; i++ ))
do
  nohup "$mydir/file-tree-worker.sh" --start-dir $start_dir --depth $depth --id $i &> "$start_dir/out"&
  pids="$pids $!"
done
log "worker pids: $pids"

while true
do
  start=$(($(date +%s%N)/1000000))
  timeout $time_limit ls -1 $start_dir | wc -l
  end=$(($(date +%s%N)/1000000))
  
  elapsed_ms=$(($end-$start))
  log "timeout: ${time_limit} s, time: $elapsed_ms ms."

  if [[ $elapsed_ms -ge $(($time_limit*1000)) ]]; then
    log "killing workers..."
    kill -9 $pids
    exit 0
  fi

  sleep 2
done