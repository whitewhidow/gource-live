#!/bin/sh -e

test $# -ge 1 || {
    echo "usage: $0 INTERVAL [STARTREV|0 RELSTART]"
    exit 1
}

INTERVAL=$1
STARTREV=$2
RELSTART=$3

test "$RELSTART" -a "$RELSTART" != 0 && NUM=$RELSTART || NUM=10
test "$STARTREV" -a "$STARTREV" != 0 && REVNO=$STARTREV || REVNO=$(svn log -q -l $NUM | sed -ne 's/^r\([0-9][0-9]*\).*/\1/p' | tail -n 1)

while true
do
    for REVNO in $(svn log -qr$REVNO:HEAD | sed -ne 's/^r\([0-9][0-9]*\).*/\1/p' | tail -n +2)
    do
        AUTHOR=$(svn log -qr $REVNO | sed -ne 2p | cut -f2 -d\| | sed -e 's/^ *//' -e 's/ *$//')
        TIMESTAMP=$(svn log -qr $REVNO | perl -MTime::Local -ne '/^r[0-9]+ .*([0-9]{4})-([0-9]{2})-([0-9]{2}) (\d\d):(\d\d):(\d\d)/ && print timelocal($6, $5, $4, $3, $2-1, $1)')
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
