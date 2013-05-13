#!/bin/sh -e

REMOTE=$1
BRANCH=$2
INTERVAL=$3

test "$4" && SHA=$4 || SHA=$(git rev-list $REMOTE/$BRANCH --max-count=10 | tail -n 1)

while true
do
    for SHA in $(git rev-list --reverse --first-parent --no-merges $REMOTE/$BRANCH $SHA..)
    do

        SUFFIXES=`git show $REMOTE/$BRANCH $SHA --pretty=format:"" --name-status | sed "s/\t/|/g"`

        for i in $SUFFIXES
        do
            SUFFIX=`echo $i| sed "s/\t/|/g"| sed "s/ //g"`
            echo ""$PREFIX"|"$SUFFIX
        done

    done
    git fetch $REMOTE >/dev/null 2>&1
    sleep $INTERVAL
done
