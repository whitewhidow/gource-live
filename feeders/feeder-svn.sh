#!/bin/sh -e

test $# -ge 1 || {
    echo "usage: $0 INTERVAL [START_REVNO]"
    exit 1
}

INTERVAL=$1
START_REVNO=$2

test "$START_REVNO" && REVNO=$START_REVNO || REVNO=$(svn log -q -l 10 | sed -ne 's/^r\([0-9][0-9]*\).*/\1/p' | tail -n 1)

while true
do
    for REVNO in $(svn log -qr$REVNO:HEAD | sed -ne 's/^r\([0-9][0-9]*\).*/\1/p' | tail -n +2)
    do
        AUTHOR=$(svn log -qr $REVNO | sed -ne 2p | cut -f2 -d\| | sed -e 's/^ *//' -e 's/ *$//')
        TIMESTAMP=$(svn log -qr $REVNO | sed -ne 2p | cut -f3 -d\| | sed -e 's/^ \([0-9 :-]*\) .*/\1/' | python -c 'from datetime import datetime as dt; import sys; ts = sys.stdin.readline().strip(); print dt.strftime(dt.strptime(ts, "%Y-%m-%d %H:%M:%S"), "%s")')
        PREFIX="$TIMESTAMP|$AUTHOR|"
        svn log -v -r$REVNO | sed -ne 's/^   \([AMD]\) /\1|/p' | while read CHANGE
        do
            echo $PREFIX$CHANGE
        done
    done
    test $INTERVAL = 0 && break
    svn up >/dev/null 2>&1
    sleep $INTERVAL
done
