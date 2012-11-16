#!/bin/sh

# Add shell envs 
LogDir=/tmp/scripts/logs

for LOG_FILE in $LogDir/*.log
do
>$LOG_FILE
done
