#!/bin/sh
#
# SCRIPT: gource-live.sh
# AUTHOR: Janos Gyerik <info@janosgyerik.com>
# DATE:   2014-02-22
# REV:    1.0.D (Valid are A, B, D, T and P)
#               (For Alpha, Beta, Dev, Test and Production)
#
# PLATFORM: Not platform dependent (confirmed in Linux)
#
# PURPOSE: Poll VCS and pipe log to Gource, to show live commits
#
# set -n   # Uncomment to check your syntax, without execution.
#          # NOTE: Do not forget to put the comment back in or
#          #       the shell script will not execute!
# set -x   # Uncomment to debug this shell script (Korn shell only)
#

usage() {
    test $# = 0 || echo $@
    echo "Usage: $0 [OPTION]... [ARG]..."
    echo
    echo Poll VCS and pipe log to Gource, to show live commits
    echo
    echo Options:
    echo "  -i, --interval INTERVAL  Interval to poll repository for changes, default = $interval"
    echo "  -s, --start START        Start revision, default = $start"
    echo "  -r, --remote REMOTE      Name of remote (Git only), default = $remote"
    echo "  -b, --branch BRANCH      Name of branch (Git only), default = $branch"
    echo "      --feed-only          Show feed only, default = $feed_only"
    echo
    echo "  -h, --help               Print this help"
    echo
    exit 1
}

args=
feed_only=off
interval=5
start=0
remote=origin
branch=master
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
    -i|--interval) shift; interval=$1 ;;
    -s|--start) shift; start=$1 ;;
    -r|--remote) shift; remote=$1 ;;
    -b|--branch) shift; branch=$1 ;;
    --feed-only) feed_only=on ;;
#    --) shift; while [ $# != 0 ]; do args="$args \"$1\""; shift; done; break ;;
    -) usage "Unknown option: $1" ;;
    -?*) usage "Unknown option: $1" ;;
    *) args="$args \"$1\"" ;;  # script that takes multiple arguments
#    *) test "$arg" && usage || arg=$1 ;;  # strict with excess arguments
#    *) arg=$1 ;;  # forgiving with excess arguments
    esac
    shift
done

eval "set -- $args"  # save arguments in $@. Use "$@" in for loops, not $@ 

#test $# -gt 0 || usage

feeders=$(dirname "$0")/feeders

if test -d .git; then
    feeder="$feeders"/feeder-git.sh
    feeder_args="$interval $start $remote $branch"
elif test -d .bzr; then
    feeder="$feeders"/feeder-bzr.sh
    feeder_args="$interval $start"
elif test -d .svn; then
    feeder="$feeders"/feeder-svn.sh
    feeder_args="$interval $start"
else
    echo Fatal: could not find .git, .bzr or .svn directory in the current directory. Are you in the root directory of a project?
    exit 1
fi


if test $feed_only = on; then
    "$feeder" $feeder_args
else
    "$feeder" $feeder_args | tee /dev/stderr | gource --log-format custom --file-idle-time 0 -
fi
