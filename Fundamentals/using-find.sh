:<<'COMMENTS'

find Command

-> Search by Time
    -atime: last accessed time
    -ctime: last changed time
    -mtime: last modified time
    -amin: last accessed time in minutes
    -cmin: last changed time in minutes
    -mmin: last modified time in minutes

    find . -type f -mtime -7
    find . -type f -atime +30

-> Search by Size
    -size: file size
    -empty: empty files
    -nouser: files with no user
    -nogroup: files with no group

    find . -type f -size +100M

-> Search by Permissions
    -perm: file permissions
    -user: file owner
    -group: file group

    find . -type f -perm 644
    find . -type f -user postgres

    # Files with suid bit enabled
    find /etc -type f -perm /4000

-> Search by User and Group
    -user: file owner
    -group: file group

    find . -type f -user postgres
    find . -type f -group postgres

-> Depth Control
    -maxdepth: maximum depth to search
    -mindepth: minimum depth to search

    find /etc -maxdepth 1 -type f

-> Execute commands on Found Files
    -exec: execute command on found files
    -execdir: execute command on found files in their directory

    find /etc -type f -exec ls -l {} \;
    find . -type f -name "*.tmp" -delete
    find . -type f -print | xargs ls -l

-> Exclude specific directories
    -prune: exclude specific directories

    # exclude node_modules directory
    find . -type f -not -path "./node_modules/*"

-> Negative an argument with "-not"

    # find files owned by postgres user in /var/lib/pgsql path
    find /var/lib/pgsql -user postgres -print

    # find files NOT owned by postgres user in /var/lib/pgsql path
    find /var/lib/pgsql -not -user postgres -print



COMMENTS

# Get inbuild examples on find using tldr command
tldr find

# Create 5 directories
mkdir /tmp/dba_log_dir_[a-e].d

# find exact match
find / -name "hosts" 2>/dev/null

# find pattern match
find / -name "*hosts*" 2>/dev/null

# files owned by postgres user
find / -user postgres

# files over 2 gb size
sudo find / -size +2G -exec ls -lhS {} \+

# files over 2 gb size with human readable format
find / -type f -size +2G -exec ls -lSh {} \+ 2>/dev/null

# copy all files with postgres keyword in name to /tmp
sudo find /etc -exec grep -l postgres {} \; -exec cp {} /tmp/ \;

# Search for text in all files in /etc directory
find /etc/ -name '*' -type f 2>/dev/null | xargs grep "127.0.0.1" 2>/dev/null

grep -rI "127.0.0.1" /etc/ 2>/dev/null

# Find all files with .conf extension and sort by size
find /etc -name "*.conf" -printf '%s, %p\n' | sort -nr

find /etc -name "*.conf" -printf '%s %p\n' | sort -nr | awk '{printf "%.2f MB, %s\n", $1/1024/1024, $2}'

du -ah /etc/*.conf | sort -hr

# Zip conf files from /etc directory to /tmp/etc_conf.tar
find /etc -maxdepth 1 -type f -name '*.conf' -exec tar -rvf /tmp/etc_conf.tar {} \;

# Find empty files
find . -type f -empty

# Find and change permissions
find . -type f -name "*.sh" -exec chmod +x {} \;

# Find conf files for postgres anywhere
find / -type d -name "postgres*" -exec find {} -type f -name "*.conf" \; 2>/dev/null

# Find conf files owned by postgres user skipping timeshift directory files
sudo find / -type f -name "*.conf" -user postgres ! -path "*/timeshift/*" 2>/dev/null

# Find .mkv/.mp4 files in /stale-storage order by size
sudo find /stale-storage -type f \( -iname "*.mkv" -o -iname "*.mp4" \) -size +500M \
    -exec ls -lh {} + | sort -k5 -h -r

# Find .mkv/.mp4 files in /stale-storage order by size and duration
sudo find /stale-storage -type f \( -iname "*.mkv" -o -iname "*.mp4" \) -size +500M -print0 | \
    while IFS= read -r -d '' file; do
        size=$(ls -lh "$file" | awk '{print $5}')
        duration=$(timeout 5 ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$file" 2>/dev/null)
        if [ -z "$duration" ]; then
            duration_fmt="ERROR"
        else
            h=$(printf "%.0f" $(echo "$duration / 3600" | bc -l))
            m=$(printf "%.0f" $(echo "($duration % 3600) / 60" | bc -l))
            s=$(printf "%.0f" $(echo "$duration % 60" | bc -l))
            duration_fmt=$(printf "%02d:%02d:%02d" $h $m $s)
        fi
        echo "$duration_fmt $size $file"
    done | sort -k1 -h -r

# Find .mkv files in /stale-storage order by size and duration
sudo find /stale-storage -type f -name *.mkv -size +500M -print0 | \
    while IFS= read -r -d '' file; do
        size=$(ls -lh "$file" | awk '{print $5}')
        duration=$(timeout 5 ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$file" 2>/dev/null)
        if [ -z "$duration" ]; then
            duration_fmt="ERROR"
        else
            h=$(printf "%.0f" $(echo "$duration / 3600" | bc -l))
            m=$(printf "%.0f" $(echo "($duration % 3600) / 60" | bc -l))
            s=$(printf "%.0f" $(echo "$duration % 60" | bc -l))
            duration_fmt=$(printf "%02d:%02d:%02d" $h $m $s)
        fi
        echo "$duration_fmt $size $file"
    done | sort -k1 -h -r




