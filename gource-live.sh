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
    echo "  -s, --startrev REV       Start revision, default = $startrev"
    echo "      --relstart N         Start from HEAD - N, ignored when startrev != 0, default = $relstart"
    echo
    echo "      --feed-only          Show feed only, default = $feed_only"
    echo
    echo "  -r, --remote REMOTE      Name of remote (Git only), default = $remote"
    echo "  -b, --branch BRANCH      Name of branch (Git only), default = $branch"
    echo
    echo "  -h, --help               Print this help"
    echo
    exit 1
}

args=
feed_only=off
interval=5
startrev=0
relstart=10
remote=origin
branch=master
while [ $# != 0 ]; do
    case $1 in
    -h|--help) usage ;;
    -i|--interval) shift; interval=$1 ;;
    -s|--startrev) shift; startrev=$1 ;;
    --relstart) shift; relstart=$1 ;;
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

test -d "$1" && project_dir="$1" || project_dir=.

if test -d "$project_dir"/.git; then
    feeder="$feeders"/git.sh
    feeder_args="$interval $startrev $relstart $remote $branch"
elif test -d "$project_dir"/.bzr; then
    feeder="$feeders"/bzr.sh
    feeder_args="$interval $startrev $relstart"
elif test -d "$project_dir"/.svn; then
    feeder="$feeders"/svn.sh
    feeder_args="$interval $startrev $relstart"
else
    echo Fatal: could not find .git, .bzr or .svn directory in the current directory. Are you in the root directory of a project?
    exit 1
fi

if test $feed_only = on; then
    "$feeder" "$project_dir" $feeder_args
else
    "$feeder" "$project_dir" $feeder_args | tee /dev/stderr | gource --log-format custom --file-idle-time 0 -
fi
