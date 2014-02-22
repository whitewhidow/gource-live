#!/bin/sh -e

test $# -ge 1 || {
    echo "usage: $0 INTERVAL [START_REVNO]"
    exit 1
}

INTERVAL=$1
START_REVNO=$2

test "$START_REVNO" -a "$START_REVNO" != 0 && REVNO=$START_REVNO || { REVNO=$(bzr revno); test "$REVNO" -gt 10 && REVNO=$(bzr revno -rlast:10) || REVNO=1; }

while true
do
    for REVNO in $(bzr log --forward --line -r $REVNO.. | tail -n +2 | sed -e 's/:.*//')
    do
        AUTHOR=$(bzr log -r $REVNO | sed -ne 's/^committer: \([^<]*\>\).*/\1/p')
        TIMESTAMP=$(bzr log -r $REVNO | sed -ne 's/^timestamp: ... \([0-9 :-]*\) +.*/\1/p' | python -c 'from datetime import datetime as dt; import sys; ts = sys.stdin.readline().strip(); print dt.strftime(dt.strptime(ts, "%Y-%m-%d %H:%M:%S"), "%s")')
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
