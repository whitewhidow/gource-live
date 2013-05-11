#!/bin/sh -e

REMOTE=$1
BRANCH=$2
INTERVAL=$3

test "$4" && SHA=$4 || SHA=$(git rev-list $REMOTE/$BRANCH --max-count=1)
#SHA=1b2be36d0f9f3d84950616a2d2fefad782118000

while true
do
    for SHA in $(git rev-list --reverse --first-parent --no-merges $REMOTE/$BRANCH $SHA..)
    do
        AUTHOR=$(git log --format=%an $SHA --max-count=1)
        TIMESTAMP=$(git log --format=%at $SHA --max-count=1)
        PREFIX="$TIMESTAMP|$AUTHOR|"
        git diff-tree --no-commit-id --name-status $SHA | tr '\t' '|' | while read SUFFIX
        do
            echo $PREFIX$SUFFIX
        done
    done
    git fetch $REMOTE >/dev/null 2>&1
    sleep $INTERVAL
done
