:<<'COMMENTS'

Understanding Processes and Jobs
------------------------------------

-> Anything that runs on Linux, runs as a process

-> A process has a Process ID (PID) and can be managed by sending signals to it

-> Signals are special operating system instructions
    -> SIGTERM (15) is the normal signal that instructs a process to stop
    -> SIGKILL (9) is the signal to force a process to stop immediately

-> Jobs are user processes that have been started from a specific shell

-> All processes originate as child from systemd
    -> systemd - PID 1
    -> kernel process
    -> sshd
    -> ..
    -> gnome-terminal
        | -> bash


Managing Interactive Shell Jobs
-------------------------------

-> When a user runs a command, this command is started as a foreground job

-> While this job is running, the current console is occupied

-> To move a running process to the background, use "Ctrl-Z, bg"

-> To start a new process in the background, use "command &"

-> Use "jobs" to get overview of current running jobs

-> Use "fg" to move a current background job to the foreground

-> Use "kill" to send a signal to terminate or manage job
    kill %<job-number>
    kill -9 <PID>

-> "wait" - Waits for a specific background process to complete

-> + or - symbol beside job ID indicate current & previous job

Monitoring Processes with top
------------------------------------------------------

-> top help us figure out uptime, load average, memory utilization, and 
    top resource consuming processes

    # open processes
    dd if=/dev/zero of=/dev/null &

-> "f" key on top to invoke "Fields Management"
    -> Once changes are done, press "q" to exit of "Fields Management"
    -> "W" key to save the top setting

    -> On Ubuntu, typically settings ~/.config/procps/toprc



Monitoring Process Properties
------------------------------------------

-> "ps" is the main command to show running processes

-> "ps aux" shows all processes, including the most useful information 
    about these processes

-> "ps fax" shows parent-child relations between processes

-> "ps" can be used with many other options to display specific properties only,
    and apply filtering

    # show top cpu-consuming processes
    ps -eo pid,ppid,%cpu,%mem,cmd --sort=-%cpu | head -n 20

    # Monitoring a specific process by PID
    ps -p <PID> -o pid,ppid,cmd,%cpu,%mem,etime

    # Find processes Using a specific command
    ps -C <command_name> -o pid,ppid,cmd,%cpu,%mem

    # Show real-time process tree
    ps -e --forest -o pid,ppid,cmd,%cpu,%mem

    # List Zombie processes
    ps -eo pid,ppid,stat,cmd | grep 'Z'

    # Show processes for a specific user
    ps -u <username> -o pid,ppid,cmd,%cpu,%mem

    # Get process states summary
    ps -eo state,pid,cmd | awk '{ state[$1]++ } END { for (s in state) print s, state[s] }'

    # Find processes using more than 90% cpu
    ps -eo pid,ppid,%cpu,cmd --sort=-%cpu | awk '$3+0 > 60'

    # Find top 20 processes by CPU
    ps -eo pid,ppid,%cpu,cmd --sort=-%cpu | head -n 20

    # List Processes in D or Uninterruptible Sleep State
    ps -eo pid,ppid,state,cmd | grep ' D '

    # Use with "watch" for Real-Time Monitoring, Every 1 second
    watch -n 1 'ps -eo pid,ppid,%cpu,%mem,cmd --sort=-%cpu | head -n 20'

TIP! Consider piping "ps" output to other tools, like "awk" and "sort" to 
    filter and sort specific output


Understanding Process Priority
----------------------------------

-> By default, user processes are started with the same priority

-> To adjust priorities, users can use "nice" to start processes with an adjusted priority
    -> Non-priviledged users can only run processes with a lower priority
    -> Priviledged users can increase and decrease process priority

-> Priorities reach from -20 (highest priority) to 19 (lowest priority)

-> To adjust priority for running processes, use "renice"

-> Process priority can also be adjusted from "top"



Managing Processes with "kill"
------------------------------------------

-> "kill" is used to send signals to a process, based on the PID

-> "killall" can do the same, based on process name

-> Common signals are:
    -> 15 (SIGTERM): instructs a process to stop
    -> 9 (SIGKILL): forces a process off

-> Get all signals
man 7 signals

COMMENTS

# Generate a long running command scenario
dd if=/dev/zero of=/dev/null &

"Ctrl+Z" to send the command to background job

# Starting a job in the background
sleep 100 &


# check existing jobs
jobs

# to start a "Stopped" job
bg

# active a background job
fg 2

# Start a command as background job using "&"
dd if=/dev/zero of=/dev/null &

# Bring a job forward, and stop the command
fg 2
"Ctrl+C"

# Kill a job
kill %<job-number>
kill -9 <PID>

# bsd style
ps aux
pf fax

# system 5 syle
ps -ef

#
ps -e -o pid,args --forest

ps aux --sort pmem

# start process with high priority
nice --help | less

sudo nice -n -10 dd if=/dev/zero of=/dev/null &

# To renice your own process
top
"R" for renice

# To renice any process
sudo top
"r" for renice


# launch multiple dd command jobs
dd if=/dev/zero of=/dev/null &
dd if=/dev/zero of=/dev/null &
dd if=/dev/zero of=/dev/null &
dd if=/dev/zero of=/dev/null &
dd if=/dev/zero of=/dev/null &

# kill process using top command
sudo top
"k" for kill

sudo kill 6344

# kill all processes running dd command
sudo killall dd

# Get postgres user running processes
ps -u postgres -o pid,ppid,%cpu,%mem,cmd --forest




