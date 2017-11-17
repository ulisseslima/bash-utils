#!/bin/bash -e

require() {
  switch=--string
  if [[ "$1" == *-* ]]; then
    switch=$1
    shift
  fi
  
  value="$1"
  msg="$2"
  
  case $switch in
    --string|-s)
      if [ ! -n "$value" ]; then
        echo "$msg"
        exit 1
      fi
    ;;
    --file|-f)
      if [ ! -f "$value" ]; then
        echo "Required file not found: '$value'"
        exit 1
      fi
    ;;
    --dir|-d)
      if [ ! -d "$value" ]; then
        echo "Required directory not found: '$value'"
        exit 1
      fi
    ;;
  esac
}

log() {
  echo "`date` - $0 thread $id - $1"
}

while test $# -gt 0
do
  case "$1" in
    --start-dir|-d)
      shift
      start_dir="$1"
    ;;
    --depth|-d)
      shift
      depth=$1
      log "--depth $depth"
    ;;
    --time-limit|-t)
      shift
      time_limit=$1
      log "--time-limit $time_limit"
    ;;
    --id)
      shift
      id=$1
      log "--id $id"
    ;;
    -*) 
      echo "ignoring unrecognized option $1"
    ;;
  esac
  shift
done

require "$depth" "--depth is not defined"
require "$start_dir" "--start-dir is not defined"
require "$id" "--id is not defined"

touch "$start_dir/$id.worker"
log "created $start_dir/$id.worker"

while true
do
  d="$start_dir"
  
  for (( i=0; i<$depth; i++ ))
  do
    random=$(cat /dev/urandom | tr -dc 'A-Z0-9' | fold -w $depth | head -n 1)
    rd="$d/$random"
    mkdir -p "$rd"
    
    f="$rd/${random}.f$i"
    log "touching $f"
    touch "$f"

    d="$rd/"
  done
done