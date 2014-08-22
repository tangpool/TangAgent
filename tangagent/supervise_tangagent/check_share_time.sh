#! /bin/sh
#
# @copyright tangpool.com
# @since 2014-08
#
SROOT=$(cd $(dirname "$0"); pwd)
cd $SROOT

PID_FILE="tangagent.pid"
# timeout: share accepted time, seconds
TIMEOUT=300

PID=`cat $PID_FILE`
LAST_TIME=`cat lastshare_time.txt`
NOW_TIME=`date +%s`
DIFF_TIME=`expr $NOW_TIME - $LAST_TIME`

# check is running
IS_EXIST=`ps aux | grep tangagent | grep $PID | wc -l`
if test $IS_EXIST -ne 1
then
  echo "tangagent is not running"
  exit 0
fi

# check timeout
if test $DIFF_TIME -gt $TIMEOUT
then
  echo "timeout, last: $LAST_TIME, now: $NOW_TIME"
  kill $PID
  sleep 10
  kill -9 $PID
fi

