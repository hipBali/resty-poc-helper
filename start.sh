#!/bin/sh

#####################################################################
# usage:
# sh start.sh -- start application @dev
# sh start.sh ${env} -- start application @${env}

# examples:
# sh start.sh prod -- use conf/nginx-prod.conf to start OpenResty
# sh start.sh -- use conf/nginx-dev.conf to start OpenResty
#####################################################################

if [ -n "$1" ];then
    PROFILE="$1"
else
    PROFILE="release"
fi

mkdir -p logs & mkdir -p tmp
echo "start resty-poc application with profile: "${PROFILE}
nginx -p `pwd`/ -c conf/nginx-${PROFILE}.conf
