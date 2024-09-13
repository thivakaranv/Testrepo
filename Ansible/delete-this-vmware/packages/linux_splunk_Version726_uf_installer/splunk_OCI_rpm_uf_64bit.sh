#!/bin/bash

# Check if script is being run as root

if [ $EUID -ne 0 ]; then
   echo This script must be run as root.
   exit 1
fi

# Check if Splunk user exists, create if NOT

getent passwd | grep splunk;
if [ $? -eq 0 ]
then
echo user splunk exists.
else
echo creating splunk user.
useradd splunk -d /opt/splunkforwarder
fi

cd /tmp/

if [ ! -s splunkforwarder-7.2.6-c0bf0f679ce9-linux-2.6-x86_64.rpm ]; then
  echo rpm package missing in /tmp please check.
  exit 2
fi

ls -lh splunkforwarder-7.2.6-c0bf0f679ce9-linux-2.6-x86_64.rpm
NEWPW=`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo ''`

#Install Splunk UF
echo Installing Splunk Universal Forarder....

rpm -ivh splunkforwarder-7.2.6-c0bf0f679ce9-linux-2.6-x86_64.rpm
/opt/splunkforwarder/bin/splunk start --accept-license --answer-yes --no-prompt --seed-password $NEWPW
sleep 20
/opt/splunkforwarder/bin/splunk set deploy-poll 10.59.240.226:8089 -auth admin:$NEWPW

#/opt/splunkforwarder/bin/splunk edit user admin -password $NEWPW -auth admin:changeme
/opt/splunkforwarder/bin/splunk enable boot-start -user splunk
for proc in `ps -ef|grep splunk|grep splunkd|grep -v grep|awk '{ print $2 }'`
do
kill -9 $proc
done
sleep 20
chown -R splunk.splunk /opt/splunkforwarder
service splunk start

#enable splunk log rotation

tar -cvf /opt/logrotate.tar /etc/logrotate.d
sed -i 's/sharedscripts/sharedscripts\n    create 664 root root/g' /etc/logrotate.d/syslog
logrotate --force /etc/logrotate.d/

###### End of Script ######
