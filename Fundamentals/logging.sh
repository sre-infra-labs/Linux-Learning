:<<'COMMENTS'

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

# On Ubuntu (default log file)
/var/log/messages

# On Redhat (default log file)
/var/log/syslogs

COMMENTS

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



