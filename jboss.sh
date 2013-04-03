#!/bin/bash -e

INSTANCES='undefined'
SERVER_NAME='default'

start() {
	jb_home="$1"
	echo "starting $jb_home..."
	exit_if_running $jb_home	
	nohup $jb_home/bin/run.sh -c $SERVER_NAME -b 0.0.0.0 &
}
stop() {
	jb_home="$1"
	process_count=`ps aux | grep -c $jb_home`
	if [[ $process_count -gt 1 ]]; then
		echo "stopping $jb_home"
		$jb_home/bin/shutdown.sh jboss
		do_clean $jb_home
		sleep 5
	fi
}
do_clean() {
	jb_home="$1"
	echo "cleaning..."
	rm -r $jb_home/server/$SERVER_NAME/tmp $jb_home/server/$SERVER_NAME/log $jb_home/server/$SERVER_NAME/work
}
exit_if_running() {
	jb_home="$1"
	if [ ! -d "$jb_home" ]; then
		echo "$1 is not a directory."
		exit 1
	fi
	process_count=`ps aux | grep -c $jb_home`
	if [[ $process_count -gt 1 ]]; then
		echo "this instance of jboss is already running."
		exit 1
	fi
}

do_start_all() {
	echo "starting all on $INSTANCES..."
	while read jb_home
	do
		start $jb_home
	done < "$INSTANCES"
}
do_stop_all() {
	while read jb_home
	do
		stop $jb_home
	done < "$INSTANCES"
	sleep 5
}
do_restart_all() {
	do_stop_all	
	do_start_all
}

do_start() {
	jb_home="$1"
	if [ ! -f "$INSTANCES" ]; then
		start "$jb_home"
	else
		do_start_all
	fi
}
do_stop() {
	jb_home="$1"
	if [ ! -f "$INSTANCES" ]; then
		stop "$jb_home"
	else 
		do_stop_all
	fi
}
do_restart() {
	jb_home="$1"	
	if [ ! -f "$INSTANCES" ]; then
		stop $jb_home
		start "$jb_home"
	else
		do_restart_all
	fi
}

do_help() {
	echo "manages a jboss instance"
	echo "usage example when $JBOSS_HOME is defined:"
	echo "$0 --start|--stop|--restart"
	echo ""
	echo "usage example when $JBOSS_HOME is NOT defined:"
	echo "$0 --jboss /path/to/jboss --restart"
	echo ""
	echo "usage with more than one jboss instance:"
	echo "$0 --instances|-f /path/to/instances.file --restart"
	echo "where each line in instances.file represent a jboss home"
}

while test $# -gt 0
do
    case "$1" in
    	--help) do_help
    		exit 0
		;;
        --name|-c) shift
        	SERVER_NAME="$1"
		;;            
        --jboss|-j) shift
        	JBOSS_HOME="$1"
		;;
        --instances|-f) shift
        	INSTANCES="$1"
		;;
        --restart|--reboot|--respawn) 
        	do_restart $JBOSS_HOME
		;;
        --stop) 
        	do_stop $JBOSS_HOME
		;;
        --start) 
        	do_start $JBOSS_HOME
		;;
        --*) echo "bad option $1"
		;;        
    esac
    shift
done

