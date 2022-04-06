#!/bin/bash
set -e

ACTIVEMQ_HOME="/opt/activemq"
cd $ACTIVEMQ_HOME

echo "check if ssl clients were given"
if [[ $(printenv | grep sslclient) ]]
then
    echo "add ssl users to users.properties"

    printenv | grep sslclient >> conf/users.properties

    echo "retrieve list of ssl users"
    for user in $(awk 'BEGIN{for(v in ENVIRON) print v}' | grep sslclient)
    do
        users=$users,$user
    done

    echo "add ssl users to admin group"
    echo "admins=admin$users" >> conf/groups.properties
fi

exec bin/activemq console "$@"
