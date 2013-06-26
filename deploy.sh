#!/bin/bash

workspace=/home/wonka/Workspaces/caixa_2013
jboss=/home/wonka/proj/servers/jboss/7.caixa
deploy=$jboss/standalone/deployments/contexpress-server.war
deploy_classes=$jboss/standalone/deployments/contexpress-server.war/WEB-INF/classes
libs=/home/wonka/proj/servers/jboss/working.lib
server_libs=$deploy/WEB-INF/lib

classes_server=$workspace/contexpress-server/src/main/webapp/WEB-INF/classes
classes_tratamento=$workspace/contexpress-tratamentodocumento/target/classes
web=$workspace/contexpress-server/target/m2e-jee/web-resources

do_deploy() {
	rm -r $jboss/standalone/data $jboss/standalone/tmp $jboss/standalone/log
	echo "rm -r $jboss/standalone/data $jboss/standalone/tmp $jboss/standalone/log"

	echo "cp -r $classes_server $deploy_classes"
	cp -r $classes_server $deploy_classes
	echo "cp -r $classes_tratamento $deploy_classes"
	cp -r $classes_tratamento $deploy_classes
	echo "cp -r $web $deploy"
	cp -r $web $deploy

	do_replace_libs
}

do_replace_libs() {
	echo "rm $server_libs/*.jar"
	rm $server_libs/*.jar
	echo "cp $libs/*.jar $server_libs"
	cp $libs/*.jar $server_libs
}

while test $# -gt 0
do
    case "$1" in
        --start)
        	do_start
        ;;
        --stop)
        	do_stop
        ;;
        --deploy)
        	do_deploy
        ;;
        --libs)
        	do_replace_libs
        ;;
        --*) echo "bad option $1"
        ;;
    esac
    shift
done

exit 0
