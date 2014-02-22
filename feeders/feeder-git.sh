#!/bin/sh -e

test $# -ge 1 || {
    echo "usage: $0 INTERVAL [START_SHA1 [REMOTE [BRANCH]]]"
    exit 1
}

INTERVAL=$1
START_SHA1=$2
REMOTE=$3
BRANCH=$4

test "$REMOTE" || REMOTE=origin
test "$BRANCH" || BRANCH=master
test "$START_SHA1" -a "$START_SHA1" != 0 && SHA=$START_SHA1 || SHA=$(git rev-list $REMOTE/$BRANCH --max-count=10 | tail -n 1)

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
