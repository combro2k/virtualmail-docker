#!/bin/bash
set -e

/etc/init.d/mysql start

if [[ ! -e /data/mysqlpass ]]; then
	echo "No mysql password set creating one"
	pwgen -1 24 -B > /data/mysqlpass && mysqladmin password `cat /data/mysqlpass`
fi

echo "MySQL connection details:"
echo "host: localhost"
echo "user: root"
echo "pass: $(cat /data/mysqlpass)"
