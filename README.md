live-git-for-gource
===================
Visualize activitiy in a Git repo (LIVE commits!)
by polling the repository for new commits and feeding the log
of changes to Gource.


Usage
-----
Copy the `git-live.sh` script to Git project you want to visualize
and run this command:

    ./git-live.sh | gource --log-format custom -

By default this will feed Gource with changes to `origin/master`,
polling the Git repository eveyr 5 seconds. You can change these
parameters by editing the variables near the top of the file.
