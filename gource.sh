#!/bin/sh

SCRIPTS_DIR=$(dirname "$0")

"$SCRIPTS_DIR"/git-live.sh $* | gource --log-format custom --file-idle-time 0 -
