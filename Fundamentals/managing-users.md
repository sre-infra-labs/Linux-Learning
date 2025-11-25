# [Creating and Managing User Accounts in Linux](https://linuxopsys.substack.com/p/creating-and-managing-user-accounts?publication_id=4995647&post_id=165542844&isFreemail=true&r=1tltv8&triedRedirect=true)


## Creating New Linux Users

- -c "Comment": adds a descriptive comment about the user
- -d /home/newuser: set the specified user’s home directory
- -m: creates the home directory if it doesn’t already exist
- -s /bin/bash: specifies the default login shel

```
# general linux
useradd -m -d /home/jane -c "Jane Doe" jane

# Debian/Ubuntu
adduser [options] <username>
```

## Modifying Linux User Accounts

### The usermod Command

Here are some key options you can use with usermod:

- -d /new/home: changes the user’s home directory
- -l new_username: renames the user’s login name
- -s /bin/zsh: changes the user’s default shell
- -L: locks a user’s account (disable logins)
- -U: unlocks a previously locked account


```
usermod [options] <username>
```

### The chage Command

chage is essential for specifically *managing password expiration and aging*.

- -M: sets the maximum number of days between password changes
- -m: sets the minimum number of days between password changes
- -w: sets the number of days before password expiry that the user receives a warning
- -d: sets the last date since the password was changed (often used with a date format like YYY-MM-DD)
- -E: sets the date the account will expire (use a date format or -1 to indicate no expiration)
- -l: lists the current password aging settings for a user

```
chage [options] <username>

# For example, let’s set jdoe to change his password every 60 days, with a minimum of 10 days between changes and a 5-day warning period
chage -M 60 -m 10 -w 5 jdoe
```

## Deleting Linux Users

### The userdel Command

- -r: removes the user’s home directory and their mail spool
- -f: forces the deletion of the user account, even if they’re currently logged in or having running processes
- -Z: removes any SELinux user mapping for the deleted user (for systems using SELinux)

```
userdel [options] <username>


# For example, to delete the user jane, her home directory, and any SELinux mappings:
userdel -rfZ jane

# Debian/Ubuntu
deluser [options] <username>

# remove user from their primary group
deluser --group <username>
```

## Managing Linux Groups

### Adding Users to Groups

```
# add user to one or more supplementary group
usermod -aG <group1>,<group2>,... <username>

usermod -aG developers,webadmin jane
```

## Monitoring User Activity

- *who*: This command provides a quick snapshot of currently logged-in users, their login time, and where they’re connected from.
- *w*: This command offers more detailed information than who, including the processes each user is running.
- *last*: This command displays a historical log of user logins and logouts. This can help track system usage patterns over time.
