#!/bin/sh -e

test $# -ge 2 || {
    echo "usage: $0 PROJECTDIR INTERVAL [STARTREV|0 RELSTART]"
    exit 1
}

PROJECTDIR=$1
INTERVAL=$2
STARTREV=$3
RELSTART=$4

test "$RELSTART" -a "$RELSTART" != 0 && NUM=$RELSTART || NUM=10
test "$STARTREV" -a "$STARTREV" != 0 && REVNO=$STARTREV || { REVNO=$(bzr revno "$PROJECTDIR"); test "$REVNO" -gt $NUM && REVNO=$(bzr revno -rlast:$NUM "$PROJECTDIR") || REVNO=1; }

while true
do
    for REVNO in $(bzr log --forward --line -r $REVNO.. "$PROJECTDIR" | tail -n +2 | sed -e 's/:.*//')
    do
        AUTHOR=$(bzr log -r $REVNO "$PROJECTDIR" | sed -ne 's/^committer: \([^<]*\>\).*/\1/p')
        TIMESTAMP=$(bzr log -r $REVNO "$PROJECTDIR" | perl -MTime::Local -ne '/^timestamp: .*([0-9]{4})-([0-9]{2})-([0-9]{2}) (\d\d):(\d\d):(\d\d)/ && print timelocal($6, $5, $4, $3, $2-1, $1)')
        PREFIX="$TIMESTAMP|$AUTHOR|"
        bzr status -c $REVNO --short --versioned "$PROJECTDIR" 2>/dev/null | sed -ne 's/^R.../M|/p' -e 's/^.N../A|/p' -e 's/^.\([MD]\)../\1|/p' | while read CHANGE
        do
            echo $PREFIX$CHANGE
        done
    done
    test $INTERVAL = 0 && break
    bzr pull -d "$PROJECTDIR" >/dev/null 2>&1
    sleep $INTERVAL
done
