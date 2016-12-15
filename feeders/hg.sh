#!/bin/sh -e

test $# -ge 2 || {
    echo "usage: $0 PROJECTDIR INTERVAL [STARTREV|0 RELSTART [REMOTE [BRANCH]]]"
    exit 1
}

PROJECTDIR=$1
INTERVAL=$2
STARTREV=$3

BASECMD="hg -R $PROJECTDIR"

test "$RELSTART" -a "$RELSTART" != 0 && NUM=$RELSTART || NUM=10
test "$STARTREV" -a "$STARTREV" != 0 && REV=$STARTREV || REV=$($BASECMD log -l 1 --template "{rev}\n")

while true
do
    for REV in $($BASECMD log --removed -r "$REV:" --template "{rev}\n")
    do
        AUTHOR=$($BASECMD log -r "$REV" --template "{author|person}\n")
        TIMESTAMP=$($BASECMD log -r "$REV" --template "{date(date,'%s')}\n")
        PREFIX="$TIMESTAMP|$AUTHOR|"
		  $BASECMD log -r "$REV" --template "{file_mods % 'M|{file}\n'}{file_adds % 'A|{file}\n'}{file_dels % 'D|{file}\n'}" \
		  | tr '\t' '|' | while read SUFFIX
        do
            echo $PREFIX$SUFFIX
        done
    done
    test $INTERVAL = 0 && break
    $BASECMD pull -u >/dev/null 2>&1
	 NEWREV=$($BASECMD log -l 1 --template "{rev}\n")
	 while [ $NEWREV = $REV ]
	 do
    	sleep $INTERVAL
		$BASECMD pull -u >/dev/null 2>&1
      NEWREV=$($BASECMD log -l 1 --template "{rev}\n")
    done
done