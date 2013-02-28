#!/bin/sh
#IFS='\n'
TAB='\t'

LASTCHECKED=`date +"%s"`

while true
do
#    IGNORED=`git svn rebase`
  PREFIXES=`git log --reverse --max-count=1 --since $LASTCHECKED --pretty=format:"%H|%at|%an|"`
    #PREFIXES=`git log --reverse --max-count=1 --pretty=format:"%H|%at|%an|"`
    LASTCHECKED=`date +"%s"`
    for i in $PREFIXES
    do
        SHA=`echo $i | cut -d '|' -f 1`
        PREFIX=`echo $i | cut -d '|' -f 2-3`
        SUFFIXES=`git show $SHA --pretty=format:"" --name-status | sed "s/\t/|/g"`
#      SUFFIXES=`echo $SUFFIXES| sed "s/\t/|/g"`


        for i in $SUFFIXES
        do
            SUFFIX=`echo $i| sed "s/\t/|/g"`
            echo ""$PREFIX"|"$SUFFIX
        done
    done
    sleep 5
done
