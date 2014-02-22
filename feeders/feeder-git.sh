#!/bin/sh -e

test $# -ge 1 || {
    echo "usage: $0 INTERVAL [STARTREV|0 RELSTART [REMOTE [BRANCH]]]"
    exit 1
}

INTERVAL=$1
STARTREV=$2
RELSTART=$3
REMOTE=$4
BRANCH=$5

test "$REMOTE" || REMOTE=origin
test "$BRANCH" || BRANCH=master
test "$RELSTART" -a "$RELSTART" != 0 && NUM=$RELSTART || NUM=10
test "$STARTREV" -a "$STARTREV" != 0 && SHA=$STARTREV || SHA=$(git rev-list $REMOTE/$BRANCH --max-count=$NUM | tail -n 1)

while true
do
    for SHA in $(git rev-list --reverse --first-parent $SHA..$REMOTE/$BRANCH)
    do
        AUTHOR=$(git log --format=%an $SHA --max-count=1)
        TIMESTAMP=$(git log --format=%at $SHA --max-count=1)
        PREFIX="$TIMESTAMP|$AUTHOR|"
        git diff-tree -r --no-commit-id --name-status $SHA | tr '\t' '|' | while read SUFFIX
        do
            echo $PREFIX$SUFFIX
        done
    done
    test $INTERVAL = 0 && break
    git fetch $REMOTE $BRANCH >/dev/null 2>&1
    sleep $INTERVAL
done
