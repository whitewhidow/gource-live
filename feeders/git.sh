#!/bin/sh -e

test $# -ge 2 || {
    echo "usage: $0 PROJECTDIR INTERVAL [STARTREV|0 RELSTART [REMOTE [BRANCH]]]"
    exit 1
}

PROJECTDIR=$1/.git
INTERVAL=$2
STARTREV=$3
RELSTART=$4
REMOTE=$5
BRANCH=$6

test "$REMOTE" || REMOTE=origin
test "$BRANCH" || BRANCH=master
test "$RELSTART" -a "$RELSTART" != 0 && NUM=$RELSTART || NUM=10
test "$STARTREV" -a "$STARTREV" != 0 && SHA=$STARTREV || SHA=$(git --git-dir "$PROJECTDIR" rev-list $REMOTE/$BRANCH --max-count=$NUM | tail -n 1)

while true
do
    for SHA in $(git --git-dir "$PROJECTDIR" rev-list --reverse --first-parent $SHA..$REMOTE/$BRANCH)
    do
        AUTHOR=$(git --git-dir "$PROJECTDIR" log --format=%an $SHA --max-count=1)
        TIMESTAMP=$(git --git-dir "$PROJECTDIR" log --format=%at $SHA --max-count=1)
        PREFIX="$TIMESTAMP|$AUTHOR|"
        git --git-dir "$PROJECTDIR" diff-tree -r --no-commit-id --name-status $SHA | tr '\t' '|' | while read SUFFIX
        do
            echo $PREFIX$SUFFIX
        done
    done
    test $INTERVAL = 0 && break
    git --git-dir "$PROJECTDIR" fetch $REMOTE $BRANCH >/dev/null 2>&1
    sleep $INTERVAL
done
