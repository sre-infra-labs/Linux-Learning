#!/bin/bash

# Written by Ajay.

echo -n "The time is currently: "
date

iostat -c | tail -n +3 | head -n 2

echo

free -h

echo

#echo -n "What user to query? "
#read user_query
#echo
#last "$user_query" | grep "$user_query"

# subshell or quoted execution
myuser=$(whoami)

echo "Looking for '$1' user last session as '$myuser'.."
echo ''

last "$1" | grep "$1" | head -n 5

echo ''
echo "Groups for '$1' user.."
groups "$1"
echo

