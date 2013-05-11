#!/bin/sh

REMOTE=origin
BRANCH=master

LASTCHECKED=`date +"%s"`

while true
do
    PREFIXES=`git log $REMOTE/$BRANCH --since=$LASTCHECKED --reverse --max-count=1 --pretty=format:"%H|%at|%an|"`
    #PREFIXES=`git log --reverse --max-count=1 --pretty=format:"%H|%at|%an|"`
    LASTCHECKED=`date +"%s"`
    for i in $PREFIXES
    do
        SHA=`echo $i | cut -d '|' -f 1`
        PREFIX=`echo $i | cut -d '|' -f 2-3`
        SUFFIXES=`git show $REMOTE/$BRANCH $SHA --pretty=format:"" --name-status | sed "s/\t/|/g"`
        # SUFFIXES=`echo $SUFFIXES| sed "s/\t/|/g"`

        for i in $SUFFIXES
        do
            SUFFIX=`echo $i| sed "s/\t/|/g" | sed "s/ //g"`
            echo ""$PREFIX"|"$SUFFIX
        done
    done
	git fetch $REMOTE  > /dev/null 2>&1
    sleep 5
done
