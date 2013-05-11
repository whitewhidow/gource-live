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
* Gource: https://code.google.com/p/gource/
* Python 2.7


Usage
-----
1. Add *this* project to your `PATH` environment variable

2. `cd` into your project's directory

3. Run `gource-live.py`

By default this will poll the repository every 5 seconds,
and feed the changes to Gource. Run `gource-live.py --help`
for more options.
