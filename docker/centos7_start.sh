#!/bin/bash

START_TIME=$(date)
date
echo using version $2
export FACTER_ONE_VERSION=$2
echo running puppet apply $1
time puppet apply $1
echo making ssh host keys
/usr/bin/ssh-keygen -A
echo starting ssh
/usr/sbin/sshd -E /var/log/sshd.log
echo starting libvirt
source /etc/sysconfig/libvirtd
/usr/sbin/libvirtd -d $LIBVIRTD_ARGS
echo starting dbus
mkdir -p /var/run/dbus
/bin/dbus-daemon --system --nopidfile
echo starting oned
su - oneadmin -c /usr/bin/oned
echo starting scheduler
su - oneadmin -c /usr/bin/mm_sched &
echo sleeping 10
sleep 10
echo adding onehost
onehost create localhost -i kvm -v kvm
echo starting sunstone
su - oneadmin -c "/usr/bin/sunstone-server start"
echo re-running puppet apply $1
time puppet apply $1
echo done
echo start time was: $START_TIME
echo now is: $(date)
cat /var/lib/one/.one/one_auth
tail -f /var/log/one/oned.log /var/log/one/sunstone.log
