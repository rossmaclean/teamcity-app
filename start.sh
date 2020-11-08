#!/bin/bash

set -eu

echo "=> Starting apache"
APACHE_CONFDIR="" source /etc/apache2/envvars
rm -f "${APACHE_PID_FILE}"
/usr/sbin/apache2 -DFOREGROUND &

echo "=> Starting TeamCity"
pwd
ls /run
ls /run/teamcity
cd /run/teamcity/bin
exec /usr/local/bin/gosu cloudron:cloudron ./runAll.sh start