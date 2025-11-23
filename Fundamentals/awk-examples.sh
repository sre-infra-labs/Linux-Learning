# Get users from /etc/passwd
awk -F : '{ print $1 }' /etc/passwd

# Get lines with length greator than 70 characters
awk 'length($0) > 70' /etc/passwd

# Get home directory of postgres user
awk -F : '/postgres/ { print $6 }' /etc/passwd
grep postgres /etc/passwd | cut -d : -f 6

# Get disk filesystem usage
df -h | awk 'BEGIN {print "\t"} {printf "%s\t%s\t%s\t%s\t%s\n", $6, $2, $3, $4, $5} END {print "\t"}'

# Get disk filesystem usage Sorted by "Use%"
df -h | awk 'NR==1 {header=$0; next} {printf "%s\t%s\t%s\t%s\t%s\n", $6, $2, $3, $4, $5}' | sort -k5 -nr | awk 'BEGIN {print "Filesystem\tSize\tUsed\tAvail\tUse%"} {print $0} END {print "\t"}'

# Get disk filesystem usage Sorted by "Use%" with Underlined Header
df -h | awk 'NR==1 {header=$0; next} {printf "%s\t%s\t%s\t%s\t%s\n", $6, $2, $3, $4, $5}' | \
  sort -k5 -nr | awk 'BEGIN {print "\033[4mFilesystem\tSize\tUsed\tAvail\tUse%\033[0m"} {print $0}' | \
  awk 'BEGIN {print "\t"} {print $0} END {print "\t"}'

# Get disk filesystem usage Sorted by "Use%" with Underlined Header, and filtered for filesystem over 2 GB
df -h | \
awk 'NR==1 {header=$0; next} \
{
  size = $2
  unit = substr(size, length(size), 1)
  num = substr(size, 1, length(size) - 1)
  
  # Convert size to GB
  if (unit == "G" && num >= 2) { 
    print $6, $2, $3, $4, $5
  }
  else if (unit == "M" && num / 1024 >= 2) {
    # Convert MB to GB
    print $6, $2, $3, $4, $5
  }
  else if (unit == "T" && num * 1024 >= 2) {
    # Convert TB to GB
    print $6, $2, $3, $4, $5
  }
}' | \
sort -k5 -nr | \
awk 'BEGIN {print "\033[4mFilesystem\tSize\tUsed\tAvail\tUse%\033[0m"} {print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5}' | \
awk 'BEGIN {print "\t"} {print $0} END {print "\t"}'





