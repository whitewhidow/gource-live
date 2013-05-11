Gource LIVE
===========
Visualize activitiy in a Git repo (LIVE commits!)
by polling the repository for new commits and feeding the log
of changes to Gource.


Usage
-----
1. Add *this* project to your `PATH` environment variable

2. `cd` into your Git project's directory

3. Run `gource-live.py`

By default this will feed Gource with changes of `origin/master`,
polling the Git repository every 5 seconds. For more options,
run `gource-live.py --help`
