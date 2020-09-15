#!/bin/bash

########################################################
# qurikuduo @ 2020-09-15 00:00:00 
# This script using linux internal shell command: ps, uptime to detect
# the specific process is exist or not. Then using curl to post a json
# String to the server.
# xxx Heartbeat detect script, if the specific process exist,
# then upload sysLoad (1 min befor now),
# else write error log to the log file.
# You can define your own heartbeat data format.
########################################################

# Heartbeat server side URL to receive heartbeat information.
SERVICE_URL='http://172.16.1.2:8091/xxxServer/heartbeat'
# Server id in ur system.
XXX_SERVER_ID=2
# Datetime string of now.
begin_time=$(date +%Y-%m-%d\ %H:%M:%S)
# Log file.
LOG_FILE="$( cd "$( dirname "$0"  )" && pwd  )"
LOG_FILE=$LOG_FILE'/xxx-heartbeat.log'
# The process command shows in ps result
PROCESS_CMD="ntp"

# Separate string into array with commas.
function str_to_array()
{
	x=$1
	OLD_IFS="$IFS" # The default IFS value is a line break
	IFS=","
	array=($x)  # Separate with commas
	IFS="$OLD_IFS" # Restore the default line break
	for each in ${array[*]}
	do
		echo $each
	done
}


echo $begin_time':' >> $LOG_FILE
PIDS=`ps -ef |grep $PROCESS_CMD |grep -v grep | awk '{print $2}'`

if [ "$PIDS" != "" ]; 
then
	LOAD_STR=`uptime | awk -F 'load average: ' '{print $2}'` # Get server load information
	echo $LOAD_STR
	arr=($(str_to_array $LOAD_STR))
	# Get CPU logic cores
	CORE_COUNT=`grep 'model name' /proc/cpuinfo | wc -l`
	echo $CORE_COUNT
	#echo ${arr[*]}
	echo ${arr[0]} # system load (1 min befor now)
	LOAD1=${arr[0]}
    echo "LOAD1=$LOAD1"
    one_hundred=100
    LOAD2=$(awk 'BEGIN{printf '$one_hundred'*'$LOAD1'}')
    echo "load1*100=$LOAD2"
    # Calculate load result: LOAD_RESULT = (1 minute load)/(CPU cores)
	LOAD_RESULT=$(awk 'BEGIN{print '$LOAD2'/'$CORE_COUNT' }')
	
	/usr/bin/curl  --connect-timeout 10 -H "Content-Type:application/json" -X POST --data '{"ServerId":'$XXX_SERVER_ID',"HeartbeatInfo":{"loadAvg1": "'$LOAD1'","sysLoad": "'$LOAD_RESULT'","cores": "'$CORE_COUNT'","memoA": "","memoB":""}}' $SERVICE_URL >> $LOG_FILE
else
	# If Process is not running, write log to log file.
	echo 'The process is not running.'>> $LOG_FILE
fi
echo >> $LOG_FILE
