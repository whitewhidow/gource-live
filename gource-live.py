#!/usr/bin/env python
#

import os
DIRNAME = os.path.abspath(os.path.dirname(__file__))

import argparse
import subprocess

parser = argparse.ArgumentParser(description='Generate a live feed of changes of a Git repo as input for Gource')
parser.add_argument('--remote', default='origin',
        help='The remote to use instead of "origin"')
parser.add_argument('--branch', default='master',
        help='The branch to use instead of "master"')
parser.add_argument('--interval', default='5',
        help='The repository polling interval to check for changes')
parser.add_argument('--sha', default='',
        help='The SHA of the start revision instead of the latest')
parser.add_argument('--show-feed', action='store_true',
        help='Show the feed and do not pipe it to gource')

args = parser.parse_args()

feeder_script = os.path.join(DIRNAME, 'feeders/feeder-git.sh')
feeder_args = [feeder_script, args.remote, args.branch, args.interval, args.sha]

if args.show_feed:
    feeder = subprocess.Popen(feeder_args)
    feeder.wait()
else:
    feeder = subprocess.Popen(feeder_args, stdout=subprocess.PIPE)
    gource = subprocess.Popen(['gource', '--log-format', 'custom', '--file-idle-time', '0', '-'], stdin=feeder.stdout)
    gource.communicate()

