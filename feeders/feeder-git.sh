#!/bin/sh -e

test $# -ge 3 || {
    echo "usage: $0 REMOTE BRANCH INTERVAL [START_SHA1]"
    exit 1
}

REMOTE=$1
BRANCH=$2
INTERVAL=$3
START_SHA1=$4

test "$START_SHA1" && SHA=$START_SHA1 || SHA=$(git rev-list $REMOTE/$BRANCH --max-count=10 | tail -n 1)

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
