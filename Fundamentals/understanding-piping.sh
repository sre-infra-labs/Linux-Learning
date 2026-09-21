:<<'COMMENTS'

Understand Piping
-----------------

A pipe is used to send the output of one command to be used as input for a second command

    ps aux | grep http

The "tee" command combines redirection and piping. It allows you to write
  output to somwhere, and at the same time use it as input for another command.

    ps aux | tee /tmp/processes.txt | grep ssh


Examples:
---------

# Monitor Real-Time Log Changes with Highlights
tail -f /var/log/syslog | grep --line-buffered "error" | sed 's/error/\x1b[31m&\x1b[0m/g'

# Find and Sort the Largest Files
sudo find /var/log -type f -exec du -h {} + | sort -rh | head -5

# Get a Weather Update in Terminal
curl -s wttr.in | grep -A 7 "Weather report" | sed 's/^[ \t]*//'

# Check System Memory and Highlight Low Free Memory
free -h | grep Mem | awk '{if ($4 ~ /[0-9]/) print "Free Memory: " $4}' | sed 's/Free Memory/\x1b[32m&\x1b[0m/'

# Create a table of Users and their Shells
cut -d: -f1,7 /etc/passwd | column -t -s: | sort

# Disk Usage Visualization in a Tree-like Format
du -h --max-depth=1 /home | sort -rh | awk '{print $2 ": " $1}'

# Search and Display Matching Files with Line Numbers
grep -rn "TODO" /path/to/project | less

# Fun with Fortune, Cowsay, and Lolcat
fortune | cowsay | lolcat

(base) ----- [2024-Dec-31 06:25:37] saanvi@ryzen9 (Linux-Learning)
|------------$ cat << EOF | cowsay | lolcat
> Learning is key to success
>
> -- Ajay Dwivedi
> EOF
 ____________________________
/ Learning is key to success \
|                            |
\ -- Ajay Dwivedi            /
 ----------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
(base) ----- [2024-Dec-31 06:26:19] saanvi@ryzen9 (Linux-Learning)

# Download and Extract in One Command
curl -L "https://example.com/file.tar.gz" | tar -xz

# Find and Replace Across Multiple Files
grep -rl "foo" . | xargs sed -i 's/foo/bar/g'

# Get Tree view of *.mkv files in folder '/hyperactive/Mastering AI Agents for Databases'
find "/hyperactive/Mastering AI Agents for Databases" -type f -name "*.mkv" | sed 's|/[^/]*$||' | sort | uniq | xargs -I {} tree -P "*.mkv" {}


# create dummmy text file (https://linuxopsys.com/linux-pipe-command-with-examples)
cat <<EOF > companies
SolarZU 250M
PostalLight 32M
Bouhannana 351M
RoyalOak 45M
Almada 274M
Streamo 142M
Bingboom 210M
EOF

# sort content. Default first header column
cat companies.txt | sort

# get top 3 companies by value
cat companies.txt | sort -nrk2 | head -n 3

    -k2 -> key/header 2nd
    -nr -> numerically reverse

# updating output. Replace one company with another
cat companies.txt | sort -nk2 | head -n3 | sed 's/Streamo/Facebook/g'

# Dealing with advanced pipelines. Get unique owners list for /etc directory items
sudo ls -la /etc | awk '{ print $4 }' | sort | uniq

# Figure out what is consuming space in /var/lib
sudo du --max-depth=1 /var | sort -nr | head -n 20 | numfmt --to iec --format "%-10f"

sudo du --max-depth=1 /var | sort -nr | numfmt --field 1 --to iec --format "%-10f" | head -n 10

sudo du --max-depth=1 /var/lib | sort -nr | head -n 20 | awk '{ print $2 " -> " $1 }'


sudo du --max-depth=1 /var/lib | sort -nr | head -n 20 | awk '{cmd="numfmt --to=iec-i --suffix=B "$1; cmd | getline h; close(cmd); print $2" -> "h}'

sudo du --max-depth=1 /var/lib | sort -nr | head -n 20 | while read size dir; do
  human_size=$(numfmt --to=iec-i --suffix=B "$size")
  echo "$dir -> $human_size"
done

# get cpu info
sudo iostat -c | tail -n +3 | head -n 2
    root@centos:~# iostat -c | tail -n +3 | head -n 2
    avg-cpu:  %user   %nice %system %iowait  %steal   %idle
              0.19    0.00    0.16    0.01    0.00   99.63

# dump raw output to file while running command
sudo iostat -c | tail -n +3 | tee /tmp/iostat_output_after_tail.txt | head -n 2

# dump raw output to file while running command
grep 'bash$' /etc/passwd | tee /tmp/bash_users.txt | cut -d: -f 1,3,7 | sort

# Set random password as well as save it to file (RHEL)
RESET_USER="rhel"

openssl rand -base64 12 | tee /tmp/${RESET_USER}-tmp-password.txt | passwd --stdin ${RESET_USER}
or
mkpasswd | tee /tmp/${RESET_USER}-tmp-password.txt | passwd --stdin ${RESET_USER}

# Set random password as well as save it to file (Ubuntu)
RESET_USER="ubuntu"
RESET_USER_PWD=$(openssl rand -base64 12)
echo ${RESET_USER}:${RESET_USER_PWD} | tee /tmp/${RESET_USER}-tmp-password.txt | sudo chpasswd
cat /tmp/${RESET_USER}-tmp-password.txt | cut -d ':' -f 2

# handling error & output in pipe. Redirecting error to /dev/null
sudo su - rhel
find / -name www 2>/dev/null > /tmp/find_www.txt
find / -name www 2>/dev/null

# put both error & output in same file
sudo su - rhel
find / -name www &> /tmp/find_www.txt


COMMENTS
