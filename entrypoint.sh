#!/bin/bash
set -e

ACTIVEMQ_HOME="/opt/activemq"
cd $ACTIVEMQ_HOME

printenv | grep sslclient >> conf/users.properties

for user in $(awk 'BEGIN{for(v in ENVIRON) print v}' | grep sslclient)
do
    users=$users,$user
done

echo "admins=admin$users" >> conf/groups.properties

exec bin/activemq console "$@"