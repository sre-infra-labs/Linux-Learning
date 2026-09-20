:<<'COMMENTS'

awk
  is great for performing more complex operations on text

It has advanced features that make it into a scripting language:
  - Regular Expressions
  - String and Numeric Functions
  - User-defined Functions
  - Control Structures

Examples:

# Get rows from /etc/passwd
awk '{print $0}' /etc/passwd

# Get rows from /etc/passwd with more than 60 characters
awk 'length($0) > 60' /etc/passwd

# Find the longest username in /etc/passwd
awk -F: 'length($1) > max {max=length($1); user=$1} END {print user, max}' /etc/passwd

# Print Usernames from /etc/passwd using colon as Field separator
awk -F : '{print $1}' /etc/passwd

# Get home directory of postgres user
awk -F : '/postgres/ { print $6 }' /etc/passwd
grep postgres /etc/passwd | cut -d : -f 6

# Get UserInfo & DefaultShell for postgres user
awk -F ':' '/postgres/ {printf "%-25s %-20s %-30s\n", $1, $7, $5}' /etc/passwd
grep postgres /etc/passwd | cut -d ":" -f 1,5,7

# Get UserInfo & DefaultShell for current user
awk -F ':' -v user="adwivedi" '$1 == user' /etc/passwd
awk -F ':' -v user="$USER" '$1 == user' /etc/passwd
awk -F ':' -v user="$USER" '$1 == user {printf "%-25s %-20s %-30s\n", $1, $7, $5}' /etc/passwd

# Get FullName (from UserInfo) & DefaultShell for current user
awk -F ':' -v user="$USER" '$1 == user {split($5, gecos, ","); printf "%-25s %-20s %-30s\n", $1, $7, gecos[1]}' /etc/passwd

# Get FullName (from UserInfo) & DefaultShell for current/postgres/adwivedi users. Add header also.
awk -F ':' -v user="$USER" '
BEGIN {
    printf "%-25s %-20s %-30s\n", "Username", "Default Shell", "Full Name"
    printf "%-25s %-20s %-30s\n", "---------------", "--------------------", "------------------------------"
}
$1 == user || $1 == "postgres" || $1 == "adwivedi" {
    split($5, gecos, ",")
    printf "%-25s %-20s %-30s\n", $1, $7, gecos[1]
}
END {
    printf "%-25s %-20s %-30s\n", "---------------", "--------------------", "------------------------------"
    printf "%-25s %-20s %-30s\n", "Username", "Default Shell", "Full Name"
}
' /etc/passwd


# Get FullName (from UserInfo) & DefaultShell for current/postgres/adwivedi users. Add header also.
awk -F ':' -v user_list="$USER,postgres,adwivedi" '
BEGIN {
    # Split user_list into an array
    split(user_list, users, ",")
    for (u in users) {
        user_array[users[u]] = 1
    }
    # Print header
    printf "%-25s %-20s %-30s\n", "Username", "Default Shell", "Full Name"
    printf "%-25s %-20s %-30s\n", "---------------", "--------------------", "------------------------------"
}
$1 in user_array {
    split($5, gecos, ",")
    printf "%-25s %-20s %-30s\n", $1, $7, gecos[1]
}' /etc/passwd



COMMENTS

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


