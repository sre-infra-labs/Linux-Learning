#!/bin/bash

# Purpose: Learning Shell Scripting
#           Optional: Receive zero or more username from commandline. If no arguments provided, then ask user to provide one
# 2026-Sep-23 - Ajay Dwivedi - Initial Draft

echo -n "The time is currently: "
date
echo

echo "********************** IOSTAT Output **********************"
iostat -c | tail -n +3 | head -n 2
echo

echo "********************** MEMORY Output **********************"
free -h
echo


input_user=$*

# check for zero length with test command
if [ -z "$input_user" ]
then
  echo -n "What user to query? "
  read input_user
  echo
fi

# subshell or quoted execution
myuser=$(whoami)

for user in $input_user;
do
  echo "********************** SESSION Output **********************"
  echo "Looking for '$user' user last session as '$myuser'.."
  echo ''

  last "$user" | grep "$user" | head -n 5

  echo ''
  echo "Groups for '$user' user.."
  groups "$user"
  echo
done

