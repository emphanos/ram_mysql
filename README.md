Takes an existing datadir in `/var/lib/mysql/` and pushed it into a ramfs
disk on `/var/ramfs` for faster I/O throughput. Also, the `make_faster.sh`
script switches the `mysqltmpdir` variable in `/etc/mysql/my.cnf` from `/tmp` to `/var/ramfs/tmp`

Should be able to deal with both Ubuntu 12.04 and 14.04 MySQL server
installs, also tested to work with MariaDB 10.

NOTE:
-----
These scripts assume you have `sudo` privileges on the system you're
modifying.

Usage:
======

Create a ramfs and copy existing mysql datadir files into it:

`./make_faster.sh`

To revert back to the previous disk bound datadir run:

`./revert_back.sh`

CAUTION:
========
When your server reboots for some reason, you'll loose your ramfs and
thus your entire MySQL database! If you're doing import work or testing
throughput, be sure to create a mysqldump to persist the database on
disk. After a reboot of the server you'll need to re-run
`make_faster.sh` since the ramfs system won't have been initialized at boot
time. You might also see that the mysql server failed to start at reboot
time since the `/var/ramfs` directory won't yet exist.
