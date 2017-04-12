#!/bin/bash

date
echo running puppet apply $1
time puppet apply $1
echo starting oned
su - oneadmin -c /usr/bin/oned
echo sleeping 10
sleep 10
echo starting sunstone
su - oneadmin -c "/usr/bin/sunstone-server start"
echo done
date
cat /var/lib/one/.one/one_auth
tail -f /var/log/one/oned.log /var/log/one/sunstone.log
