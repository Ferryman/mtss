#!/bin/sh

# Add shell envs 
LogDir=/tmp/scripts/logs
DataDir=/tmp/scripts/data
IPAddress=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{print $1}'`
process_name=`basename $0`

# Admin email address
AdminEmail=`cat $DataDir/admin_emails|tr '\n' ','`

log()
{
# write logs 
# Usage: log "$_level" "$_msg"

_level=$1
_msg=$2
echo "$_level: $(date) | Process: $process_name : $_msg"
echo "$(date)|$process_name|$_level|$_msg" >>$LogDir/$process_name.log

}

for LOG_FILE in $LogDir/*.log
do
        /bin/grep "ERROR" $LOG_FILE > $DataDir/mailbody
        if [[ -s $DataDir/mailbody ]]
        then
                cat $DataDir/mailbody|/bin/mail -s "project mtss error report. $LOG_FILE on $IPAddress" $AdminEmail 2>&1 &&  log INFO "$process_name stopped" || log ERROR "$process_name quit unexpectly"   
        fi
        >$LOG_FILE
done
