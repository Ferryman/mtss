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
	cat $DataDir/mailbody|/bin/mail -s "project mtss error report. $LOG_FILE on $IPAddress" 2>&1 &&  log INFO "purge_log.sh stopped" || log ERROR "purge_log.sh quit unexpectly"	 
	>$LOG_FILE
done

log()
{
# write logs
# Usage: log "$_level" "$_msg"

_level=$1
_msg=$2
echo "$_level: $(date) | Process: $process_name : $_msg"
echo "$(date)|$process_name|$_level|$_msg" >>$LogDir/purge_log.log

}