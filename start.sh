#!/bin/sh

#####################################################################
# usage:
# sh start.sh -- start application @test
# sh start.sh ${env} -- start application @${env}
# examples:
# sh start.sh dev -- use conf/nginx-dev.conf to start OpenResty
# sh start.sh -- use conf/nginx-test.conf to start OpenResty
#####################################################################

if [ -n "$1" ];then
    PROFILE="$1"
else
    PROFILE="test"
fi

mkdir -p logs & mkdir -p tmp
echo "start lor application with profile: "${PROFILE}
nginx -p `pwd`/ -c conf/nginx-${PROFILE}.conf
