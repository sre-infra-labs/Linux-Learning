:<<'COMMENTS'

Youtube - https://www.youtube.com/live/CeN2PnXyeuE?si=2fXZX65nEZ-Lcf2N


Linux Logging Overview
-----------------------------

-> Syslog is the legacy service that takes care of logging

-> Syslog on modern Linux is implemented through "rsyslogd"

-> "systemd-journald" is a systemd integrated log service

-> On some distributions, "systemd-journald" is the only logging service still offered


JournalCtl Command Overview
------------------------------------

-> "journalctl" shows the complete journal

-> "journalctl -u <unit>" shows information about specific unit (use tab completion)

-> "journalctl --dmesg" shows kernel messages

-> Combined filters can be used:
    journalctl -u crond --since yesterday --until 9:00 -p info


Making the Journal Persistent
---------------------------------

-> By default, the systemd journal is not persistent

-> Most Linux distributions have "Storage=auto" in /etc/systemd/journald.conf

-> If this setting is used, create a directory /var/log/journal to save the
    journal persistently


Understanding Rsyslogd
--------------------------------

-> The "rsyslogd" service works with facility, priority, and destination

-> The facility is what "rsyslogd" should be logging for

-> The priority indicates the severity of a log event

-> The destination defines where the message should be written to

# Rsyslogd config files.
/etc/rsyslog.conf

# On Rhel (default log file)
/var/log/messages

# On Ubuntu (default log file)
/var/log/syslog


Log messages from applications
---------------------------------
-> Applications can log messages to syslog using the "logger" command
man logger


Rotating log files automatically
--------------------------------------
-> Log files can grow very large over time
-> Logrotate is a utility that can be used to rotate log files automatically

cat /etc/logrotate.conf
    # see "man logrotate" for more details


COMMENTS

# read latest log
tail /var/log/system
tail /var/log/messages

# On Ubuntu, read log messages for particular time for 5 minutes
grep '2026-10-08T07:3[0-5]' /var/log/syslog
grep 'Oct  8 13:2[5-9]' /var/log/messages

# check log
sudo journalctl
# view logs since last boot
journalctl -b
# Follow logs for a specific time range
journalctl --since "2025-01-13 10:00:00" --until "2025-01-13 12:00:00"
# Filter logs by Unit (service)
journalctl -u ngix
# Filter logs by Priority level
    # Replace priority with levels like emerg, alert, crit, err, warning, notice, info, or debug
journalctl -p priority
# By Specific User:
journalctl _UID=1000
# Limit output
journalctl -n 50
# Export logs
journalctl > system_logs.txt


# check logs for postgres
journalctl -u postgres

# check live new log entries (refresh)
    # in terminal 01
    sudo journalctl -f

    # in terminal 02, and put wrong password
    su -

# 
sudo vim /etc/systemd/journald.conf

# Write something to systemlog
logger HELLO
logger "ERROR"

# Logging with a tag
logger -t ansible -p info "Hi Ajay. This is info log."
logger -t ansible -p user.warning "Hi Ajay. Warning as your system is running out of disk space"

logger -t ansible -p user.err "Hi Ajay. Some error occurred"
logger -t ansible -p authpriv.err "Hi Ajay. Some access related error occurred"

logger -t ansible -p user.crit "Hi Ajay. Some critical error occurred"

# Retreive above ansible tagged log from syslog for "user" facility
grep  '\sansible:' /var/log/syslog
    2026-10-08T14:49:46.027872+05:30 ryzen9 ansible: Hi Ajay. Some error occurred

# Retreive above ansible tagged log from syslog for "authpriv" facility
grep Ajay /var/log/auth.log
    2026-10-08T14:57:56.972423+05:30 ryzen9 ansible: Hi Ajay. Some error occurred

# Find where cron job entries are logged
grep -i cron /etc/rsyslog.conf /etc/rsyslog.d/*.conf
    /etc/rsyslog.d/50-default.conf:#cron.*                          /var/log/cron.log
    /etc/rsyslog.d/50-default.conf:#        cron,daemon.none;\

# Write a rule to log debug priority messages to /tmp/debug.log
sudo tee /etc/rsyslog.d/debug.conf <<'EOF'
# Add the following line to the file:
*.=debug      /tmp/debug.log
EOF

sudo systemctl restart rsyslog

logger -t ansible -p user.debug "Hi Ajay. This is debug message from python code. Ignore it."
cat /var/log/debug.log
    2026-10-08T15:23:15.943574+05:30 ryzen9 ansible: Hi Ajay. This is debug message from python code. Ignore it.




