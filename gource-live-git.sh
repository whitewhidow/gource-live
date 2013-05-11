#!/bin/sh

FEEDER=$(dirname "$0")/feeders/feeder-git.sh

$FEEDER $* | gource --log-format custom --file-idle-time 0 -
