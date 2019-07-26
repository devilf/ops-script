#!/bin/bash

basedir="/export/servers/cashloan-center"
OPTS="-Dtrace.workerId=0 -Dtrace.dataCenterId=0"
ARGS=`getopt -a -o e:m --long env:,module: -- "$@"`

eval set -- "${ARGS}"

while :
do
        case $1 in
                -e|--env)
                        Env=$2
                        shift
                        ;;
                -m|--module)
                        Module=$2
                        shift
                        ;;
                --)
                        shift
                        break
                        ;;
                *)
                        echo "Please input ENV"
                        exit 1
                        ;;
        esac
shift
done

stop_server() {
	while :
	do
		pros=$(ps -ef | grep cashloan-center-${Module} | grep -v grep | wc -l)
		if [ $pros -ne 0 ];then
			ps -ef | grep cashloan-center-${Module} | grep -v grep | awk '{print $2}' | xargs kill -9 >/dev/null &
                        sleep 0.5
			if [ $(ps -ef | grep cashloan-center-${Module} | grep -v grep | wc -l) -eq 0 ];then
				echo "${Module} stop successfull."
				return
			else
				echo "${Module} stop faild."
			fi
		else
			echo "${Module} pro is not exist."
			return
		fi
	done
}

start_server() {
        while :
        do
                pros=$(ps -ef | grep cashloan-center-${Module} | grep -v grep | wc -l)
                if [ $pros -eq 0 ];then
                        cd $basedir/${Module}-server
			nohup java $OPTS -jar cashloan-center-${Module}.jar --spring.profiles.active=${Env} >/dev/null 2>&1 &
			#nohup java -jar cashloan-center-$1.jar >/dev/null &
                        sleep 0.3
                        if [ $(ps -ef | grep cashloan-center-${Module} | grep -v grep | wc -l) -ne 0 ];then
                                echo "${Module} start successfull."
                                return
                        else
                                echo "${Module} start faild."
                        fi      
                else
                        stop_server --env=$Env --module=$Module
                fi
        done
}

start_server
