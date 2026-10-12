# Encrypting and signing data, gpg on linux

- Youtube - https://www.youtube.com/watch?v=76Knb4ft3u4

```bash

# generate encryption key for both users
gpg --gen-key

# check public keys
gpg --list-keys

gpg --list-secret-keys

# take out last 8 characters of public key, and export it to share with other user
  # under user2 session
gpg --export pub_key_of_user > /tmp/user2.gpg.pub
  # under user1 session
gpg --export pub_key_of_user > /tmp/user1.gpg.pub

# Import public key of other user
  # under user1 session
gpg --import /tmp/user2.gpg.pub
gpg --list-keys
  # under user2 session
gpg --import /tmp/user1.gpg.pub
gpg --list-keys

# Suppose user1 wants to send a sensitive file to user2
  # User1
cd ~
cp /etc/passwd file-for-user2

gpg --encrypt file-for-user2
  # this generates a gpg encrypted file with <file>.gpg extension
file file-for-user2.gpg


# User2
gpg --decrypt /tmp/file-for-user2.gpg

#
sha256sum /home/$USER/file-for-user2

```


 