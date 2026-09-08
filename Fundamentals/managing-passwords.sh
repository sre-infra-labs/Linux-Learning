:<<'COMMENTS'

Managing Passwords
------------------

-> Users can change their password using "passwd"

-> Administrators can manage passwords and their properties using "passwd" and "chage"
    -> Use "chage -l" to list password properties
    -> Use "chage" for prompts about all changeable settings
    -> Use different options with "passwd -S" and "chage" to change password properties

-> To change passwords without interactive prompt:
    -> On Redhat, "echo password | passwd --stdin username"
    -> On Ubuntu, "echo username:password | chpasswd"
    -> On Ubuntu, "yes password | sudo passwd username" (not recommended, as it will show password in process list)

    sudo sh -c 'echo password | passwd --stdin username'
    echo username:password | sudo chpasswd

-> Password settings are written to /etc/shadow

-> Ubuntu has PAM (Pluggable Authentication Modules) for password management sitting in background to regular pasword policies.
    -> Example, password complexity, password expiration etc

COMMENTS

# Get password status ofr current user
sudo passwd -S $(whoami)
sudo passwd -S $USER

# Change password attributes for user
sudo chage adwivedi

# Get password information for user
sudo grep adwivedi /etc/shadow

# get config of /etc/shadow
man 5 shadow

# change password for user
sudo passwd adwivedi

# better way to change password.
    #This method allows to change password for multiple users easily

# On Redhat
echo 'mycomplexpassword' | sudo passwd --stdin adwivedi
# On Ubuntu
echo 'adwivedi:mycomplexpassword' | sudo chpasswd







