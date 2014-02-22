Gource LIVE
===========
Visualize activitiy in a VCS branch (LIVE commits!) by polling
the repository for new commits and feeding the log
of changes to Gource.

Supported VCS:

* Git
* Bazaar
* Subversion


Requirements
------------
* Gource: https://github.com/acaudwell/Gource
* Bash, Perl


Running gource live
-------------------
1. Add *this* project to your `PATH` environment variable

2. `cd` into your project's work tree (= local clone, checkout)

3. Run `gource-live.sh` or `/path/to/this/project/gource-live.sh`

You could also specify the work tree on the command line, for example:

    ./gource-live.sh /path/to/work/tree

By default this will poll the repository every 5 seconds,
and feed the changes to Gource. Run `gource-live.sh --help`
for more options.


Debugging gource live
---------------------
The script has some helpful flags for debugging.

To see what logs would be piped to Gource,
the `--feed-only` flag is helpful, and it's also practical to set
the polling interval to 0 using the `-i` flag, which will effectively
make the feeder script exit after a single run:

    ./gource-live.sh --feed-only -i 0 /path/to/work/tree

It can be also useful to debug the feeder scripts directly,
for example:

    ./feeders/bzr.sh /path/to/bzr/branch 0

You can run the feeder scripts without any parameters to print
the usage help and see what parameters they need, for example:

    $ ./feeders/svn.sh 
    usage: ./feeders/svn.sh PROJECTDIR INTERVAL [STARTREV|0 RELSTART]


TODO
====
More feature ideas to do someday.

- add support for hg (mercurial)

- bzr and svn could work without a local clone, getting info off the repo url

- embed sample repos and a harness for easier testing
