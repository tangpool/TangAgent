#! /bin/sh
#
# @copyright tangpool.com
# @since 2014-08
#
SROOT=$(cd "$(dirname "$0")"; pwd)
cd "$SROOT"

# timeout: share accepted time, seconds
TIMEOUT=300

if [[ ! -e lastshare_time.txt ]]; then
    echo 'lastshare_time.txt not exists!' >&2
    exit 1
fi

LAST_TIME=`cat lastshare_time.txt`
NOW_TIME=`date +%s`
DIFF_TIME=`expr $NOW_TIME - $LAST_TIME`

PROGRAME_NAME=agent_`basename "$SROOT"`

# check running
status=`supervisorctl status "$PROGRAME_NAME" | awk '{ print $2 }'`
if [[ "$status" != "RUNNING" ]]; then
    echo 'not running' >&2
    exit 2
fi

# check timeout
if [[ $DIFF_TIME -gt $TIMEOUT ]]; then
  echo "timeout, last: $LAST_TIME, now: $NOW_TIME, programe_name: $PROGRAME_NAME" >&2
  supervisorctl restart "$PROGRAME_NAME"
fi

exit 0
