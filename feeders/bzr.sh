#!/bin/sh -e

test $# -ge 1 || {
    echo "usage: $0 INTERVAL [STARTREV|0 RELSTART]"
    exit 1
}

INTERVAL=$1
STARTREV=$2
RELSTART=$3

test "$RELSTART" -a "$RELSTART" != 0 && NUM=$RELSTART || NUM=10
test "$STARTREV" -a "$STARTREV" != 0 && REVNO=$STARTREV || { REVNO=$(bzr revno); test "$REVNO" -gt $NUM && REVNO=$(bzr revno -rlast:$NUM) || REVNO=1; }

while true
do
    for REVNO in $(bzr log --forward --line -r $REVNO.. | tail -n +2 | sed -e 's/:.*//')
    do
        AUTHOR=$(bzr log -r $REVNO | sed -ne 's/^committer: \([^<]*\>\).*/\1/p')
        TIMESTAMP=$(bzr log -r $REVNO | perl -MTime::Local -ne '/^timestamp: .*([0-9]{4})-([0-9]{2})-([0-9]{2}) (\d\d):(\d\d):(\d\d)/ && print timelocal($6, $5, $4, $3, $2-1, $1)')
        PREFIX="$TIMESTAMP|$AUTHOR|"
        bzr status -c $REVNO --short --versioned 2>/dev/null | sed -e 's/.\(.\)../\1|/' | while read CHANGE
        do
            echo $PREFIX$CHANGE
        done
    done
    test $INTERVAL = 0 && break
    bzr pull >/dev/null 2>&1
    sleep $INTERVAL
done
