:<<'COMMENTS'

sed
  Awk is useful for filtering text and printing specific values only
  Sed is a stream editor, and allows you to edit files in non-visual mode
  Sed is GNU stream editor for filtering and transforming text.
    It is a non-interactive command-line tool that processes text in a pipeline, making it suitable for batch processing and automation tasks.

s    substitute
d    delete
p    print
i    insert
a    append
c    change

-n   don't automatically print
-i   edit file in place

Examples:

# Print 5th line of /etc/passwd
sed -n 5p /etc/passwd

head -5 /etc/passwd | tail -1

# Substitue word "old" with "new" in myfile (In Place)
sed -i 's/old/new/g' ./Fundamentals/myfile

# Delete 6th line of myfile (In Place)
sed -i -e '6d' ./Fundamentals/myfile

# Delete 6th & 8th line of myfile (In Place)
sed -i -e '6,8d' ./Fundamentals/myfile

# Create multiple files using Globbing
echo hello | tee file{1..4}.txt

# Substitute word "hello" with "bye" in all files
for i in *txt; do sed -i 's/hello/bye/g' $i; done

COMMENTS

:<<'PRACTICE'

# create a practice file
cat > test.txt <<EOF
root:x:0:0:root:/root:/bin/bash
alice:x:1001:1001:Alice:/home/alice:/bin/bash
bob:x:1002:1002:Bob:/home/bob:/bin/bash
postgres:x:1003:1003:Postgres:/var/lib/pgsql:/bin/nologin
EOF

# Read file, substitute "alice" with "ALICE", and print result to stdout (without changing the file)
  # Any of the characters can be used as delimiter, but the most common is "/"
sed 's/alice/ALICE/' test.txt
sed 's#alice#ALICE#' test.txt
sed 's|alice|ALICE|' test.txt

# Substitue word "alice" with "ALICE" in myfile (In Place)
sed -i 's/alice/ALICE/' test.txt

# `sed` changes only the first occurrence by default
echo "hello hello hello" | sed 's/hello/HELLO/'

# To replace every occurrence, use the "g" flag (global)
echo "hello hello hello" | sed 's/hello/HELLO/g'

# `sed` is line-oriented, so it processes one line at a time. If you want to replace across multiple lines, you can use the "N" command to append the next line to the pattern space.

# Delete lines with `d`

cat > users.txt <<EOF
root
alice
bob
testuser
oracle
EOF

sed '3d' users.txt  # Delete the 3rd line
sed '2,4d' users.txt  # Delete lines 2 to 4
sed '/alice/d' users.txt  # Delete lines containing "alice"
sed -n '2p' users.txt  # Print only the 2nd line

sed -n '/alice/p' users.txt  # Print lines containing "alice"
grep 'alice' users.txt  # Print lines containing "alice"

sed -n 's/alice/Alice/p' users.txt  # Substitute "alice" with "Alice" and print the line

sed -i.bak 's/alice/ALICE/' test.txt # Substitue word "alice" with "ALICE" in myfile (In Place) and create a backup file with .bak extension

# Beginning of line
sed '/^root/p' users.txt

# End of line
sed '/bash$/p' /etc/passwd

# Bigginng of line and end of line
sed -n '/^root.*bash$/p' test.txt

# Multiple sed commands
sed -e 's/alice/ALICE/' -e 's/bob/BOB/' users.txt

# Find port no for httpd service and change it
grep -n 'Listen' /etc/httpd/conf/httpd.conf

  # check first
sed 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf
  # update if confident
sed -i.bak 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf
grep -n 'Listen' /etc/httpd/conf/httpd.conf

# Add lines with `a` (append) and `i` (insert)
cat users.txt
    root
    alice
    bob
    testuser
    oracle

sed '2a\adwivedi' users.txt  # Append "adwivedi" after line 2
    root
    alice
    adwivedi
    bob
    testuser
    oracle

sed '3i\adwivedi' users.txt  # Insert "adwivedi" before line 3
    root
    alice
    adwivedi
    bob
    testuser
    oracle

# Change an entire line with `c` (change)
sed '2c\adwivedi' users.txt  # Change line 2 to "adwivedi"
    root
    adwivedi
    bob
    testuser
    oracle

PRACTICE

