#!/bin/sh -e
#

INTERVAL=$1; shift

test "$1" && REVNO=$1 || REVNO=$(svn info | sed -ne 's/Revision: //p')

while true
do
    for REVNO in $(svn log -qr$REVNO:HEAD | sed -ne 's/^r\([0-9][0-9]*\) \| .*/\1/p' | tail +2)
    do
        AUTHOR=$(svn log -qr $REVNO | sed -ne 2p | cut -f2 -d\| | sed -e 's/^ *//' -e 's/ *$//')
        TIMESTAMP=$(svn log -qr $REVNO | sed -ne 2p | cut -f3 -d\| | sed -e 's/^ \([0-9 :-]*\) .*/\1/' | python -c 'from datetime import datetime as dt; import sys; ts = sys.stdin.readline().strip(); print dt.strftime(dt.strptime(ts, "%Y-%m-%d %H:%M:%S"), "%s")')
        PREFIX="$TIMESTAMP|$AUTHOR|"
        svn log -v -r$REVNO | sed -ne 's/^   \([AMD]\) /\1|/p' | while read CHANGE
        do
            echo $PREFIX$CHANGE
        done
    done
    svn up >/dev/null 2>&1
    sleep $INTERVAL
done
