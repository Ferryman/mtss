#!/bin/sh

# Add shell envs 
LogDir=/tmp/scripts/logs
DataDir=/tmp/scripts/data
IPAddress=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{print $1}'`
# Admin email address
AdminEmail=admin@foo.bar

for LOG_FILE in $LogDir/*.log
do
	/bin/grep "ERROR" $LOG_FILE > $DataDir/mailbody
	cat $DataDir/mailbody|/bin/mail -s "project mtss error report. $LOG_FILE on $IPAddress" 	 
	>$LOG_FILE
done
