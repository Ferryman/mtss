#!/bin/sh 


###########################################################################
# help
###########################################################################


help()
{
cat <<EOF
Options:
        -h	Display this screen (eg. nohup $ScriptDir/$ScriptName -h &)
        -r 	Run processes (eg. nohup $ScriptDir/$ScriptName -r process_full_path limit idle_time &)      
EOF
exit 0
}


test()
{
# test 
date_format_conversion "-" week_hour
exit 0
}


##########################################################################
# module function
##########################################################################

log()
{
# write logs
# Usage: log "$_level" "$_msg"

_level=$1
_msg=$2
echo "$_level: $(date) | Process: $process_name : $_msg"
echo "$(date)|$process_name|$_level|$_msg" >>$LogDir/$process_name.log

}


date_format_conversion()
{
_day=$1
_format_name=$2

case $_format_name in 
        common) format="%Y%m%d" ;; 
        minus) format="%Y-%m-%d" ;; 
	week) format="%Y%m%d.%V%w" ;;
	hour) fromat="%Y%m%d%H" ;;
	week_hour) format="%Y%m%d.%V%w.%H" ;;
	common_short) format="%y%m%d" ;; 
	*) break;;
esac

echo $(date --date="$_day" +$format)
exit 0
}

#############################################################################
# functions
#############################################################################

worker_processes()
{

process_num=`ps -ef | grep "$process_name" | grep -v grep | grep -v $ScriptName | wc -l`
process_num_left=$((limit-process_num))
while [ $process_num_left -le 0 ]
do
log INFO  "$process_num $process processes running. Limit reached. Sleep 5s then check again."
sleep 5
process_num=`ps -ef | grep "$process_name" | grep -v grep | grep -v $ScriptName | wc -l`
process_num_left=$((limit-process_num))
done
}

run()
{

process_num=0

while :
do
log INFO "Starting a $process_name process..."
process_num=$((process_num+1))
#process_num_left=`expr $limit - $process_num`
process_num_left=$((limit-process_num))
log INFO  "$process_name #$process_num started."
$sh $process_full_path >>$LogDir/$process_name.log 2>&1 && log INFO "$process_name #$process_num stopped" || log ERROR "$process_name #$process_num quit unexpectly" &
log INFO  "$process_num $process_name processes running. $process_num_left $process_name processes left."
log INFO  "Sleep $idle_time to start another process."
sleep $idle_time
worker_processes
done
}


#############################################################################
# main
#############################################################################

# Add shell env to cron script
# source $HOME/.keychain/${HOSTNAME}-sh

# Add shell envs 
PATH=$PATH
ScriptName="$( basename "$0" )"
ScriptDir="$( cd "$( dirname "$0" )" && pwd )"
DataDir=/tmp/scripts/data
LogDir=/tmp/scripts/logs

mkdir -p $DataDir $LogDir

# Help
if [ $# -eq 0 ] 
then
help
fi 

process_full_path=$2
process_name=$(basename "$process_full_path")
#echo $process_name;exit 0;
ext=$(echo $process_name |awk -F . '{if (NF>1) {print $NF}}')

case $ext in
	php) sh=`which php`;;
	sh) sh=`which sh`;;
	*) echo "error: no shell";exit 1;;
esac

limit=$3
idle_time=$4


while [ -n "$1" ]; do 
case $1 in 
        -h) help;shift 1;; # function help is called 
        -test) test;shift 1;; #test functions
	-r) run;shift 1;; 
	-l) load $2 $3 $4;shift 4;;
	--) shift;break;; # end of options 
        -*) echo "error: no such option $1. -h for help";exit 1;;
        *) break;;
esac
done


