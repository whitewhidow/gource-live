#!/bin/sh -e
#
# TODO: rewrite using Python and bzrlib

INTERVAL=$1; shift

test "$1" && REVNO=$1 || REVNO=$(bzr revno)

while true
do
    for REVNO in $(bzr log --forward --line -r $REVNO.. | tail +2 | sed -e 's/:.*//')
    do
        AUTHOR=$(bzr log -r $REVNO | sed -ne 's/^committer: \([^<]*\).*/\1/p')
        TIMESTAMP=$(bzr log -r $REVNO | sed -ne 's/^timestamp: ... \([0-9 :-]*\) +.*/\1/p' | python -c 'from datetime import datetime as dt; import sys; ts = sys.stdin.readline().strip(); print dt.strftime(dt.strptime(ts, "%Y-%m-%d %H:%M:%S"), "%s")')
        PREFIX="$TIMESTAMP|$AUTHOR|"
        bzr status -r $((REVNO-1)) --short 2>/dev/null | sed -e 's/.\(.\)../\1|/' | while read CHANGE
        do
            echo $PREFIX$CHANGE
        done
    done
    bzr pull >/dev/null 2>&1
    sleep $INTERVAL
done
