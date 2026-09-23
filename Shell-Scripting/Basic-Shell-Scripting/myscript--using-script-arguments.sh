#!/bin/bash

# Purpose: Learning Shell Scripting
#          Optional: Receive zero or more username from commandline. If no arguments provided, then ask user to provide one
# 2026-Sep-23 - Ajay Dwivedi - Initial Draft
# ================================================
# Help:
#   man bash
#   > Search for "CONDITIONAL EXPRESSIONS"
# ================================================


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
  echo "command-line arguments not-detected."
  echo
  echo -n "What user to query? "
  read input_user
  echo
else
  echo "command-line arguments provided."
  echo
fi

# subshell or quoted execution
myuser=$(whoami)

for user in $input_user;
do
  echo "********************** SESSION Output for User [$user] **********************"
  echo "Looking for '$user' user last session as '$myuser'.."
  echo ''

  last_data=$(last "$user" | grep "$user" | head -n 5)
  if [ -n "$last_data" ]
  then
    echo $last_data
  else
    echo "No last login data available for $user"
  fi

  echo ''
  echo "Groups for '$user' user.."
  groups "$user"
  echo
done

echo
echo -n "Enter list of files to check: "
read input_files
echo

for file in $input_files;
do
  echo "****** Working on file [$file] ********"
  if [ -e $file ] && [ -r $file ]; then
    #echo "File $file exists and is readable"
    ls -l $file
  elif [ -e $file ]; then
    echo "File $file is not readable"
  else
    echo "File $file does not exist."
  fi
done
echo
