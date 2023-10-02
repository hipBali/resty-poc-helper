#!/bin/sh

#####################################################################
# usage:
# sh stop.sh -- stop application @test
# sh stop.sh ${env} -- stop application @${env}

# examples:
# sh stop.sh dev -- use conf/nginx-dev.conf to stop OpenResty
# sh stop.sh -- use conf/nginx-test.conf to stop OpenResty
#####################################################################

if [ -n "$1" ];then
    PROFILE="$1"
else
    PROFILE="test"
fi

mkdir -p logs & mkdir -p tmp
echo "stop resty-poc application with profile: "${PROFILE}
nginx -s stop -p `pwd`/ -c conf/nginx-${PROFILE}.conf
