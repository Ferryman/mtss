#!/bin/sh

# Add shell envs 
LogDir=/tmp/scripts/logs
DataDir=/tmp/scripts/data
IPAddress=`/sbin/ifconfig eth0 | /bin/grep 'inet addr:' | /usr/bin/cut -d: -f2 | /usr/bin/awk '{print $1}'`
process_name=`/usr/bin/basename $0`

# Admin email address
AdminEmail=`cat $DataDir/admin_emails|/usr/bin/tr '\n' ','`

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
        /bin/grep -v "INFO" $LOG_FILE > $DataDir/mailbody
        if [[ -s $DataDir/mailbody ]]
        then
                cat $DataDir/mailbody|/bin/mail -s "mtss error report. `/usr/bin/basename $LOG_FILE` on $IPAddress" $AdminEmail 2>&1 &&  log INFO "$process_name stopped" || log ERROR "$process_name quit unexpectly"   
        fi
        >$LOG_FILE
done
