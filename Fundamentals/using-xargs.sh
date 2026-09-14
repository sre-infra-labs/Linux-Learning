:<<'COMMENTS'

-> The "xargs" command is used to build and execute command lines from standard input.
    It takes input (like a lit of filenames from "find" command) and
    executes a command (eg, ls, cp, rm) on each item in the input

xargs Syntax:
    xargs [options] [command [initial-arguments]]

Options: Control how "xargs" behaves (eg, handle spaces, limit execution, etc)

Key Options for xargs:
    -0: Use NULL as delimiter. Useful when handling filenames with spaces
    -I: Replace string with input. Useful when you want to use input in the middle of the command
    -n: Limit the number of arguments passed to the command
    -P: Run multiple processes in parallel

Examples:

    # Example 01. create 2 files
    echo "file1.txt file2.txt" | xargs touch

    # Example 02. find files in /etc, and list permissions.
        # NOTE: If any file name contains spaces, xargs might misinterpret it
    find /etc/ -type f | xargs ls -l
        # To not include child directories
    find /etc/ -maxdepth 1 -type f | xargs ls -l

    # Example 03. Handling filenames with spaces
    cd /tmp
    mkdir dump_files
    touch "my long file name.txt"

    find /tmp/ -maxdepth 1 -type f | xargs -d '\n' ls -l
    find /tmp/ -type f -print0 | xargs -0 ls -l

    # Example 04. Using -0 option to handle filenames with spaces
      # find files in /var/log with .log extension and list their details.
        # This will handle a file name like "my application.log" correctly. Without -0, it would treat "my" and "application.log" as separate files.
    find /var/log -name "*.log" -print0 | xargs -0 ls -lh


    # Example 05. Using -I option
        # get files on dump_files directory
    find ./dump_files/ -maxdepth 1 -type f
        # delete all files in dump_files directory
    find ./dump_files/ -type f | xargs -d '\n' rm -f
        # copy
    find . -maxdepth 1 -type f -name 'file?.txt' | xargs -d '\n' -I {} cp {} ./dump_files/
    echo "file1.txt file2.txt" | xargs -I {} cp {} ./dump_files/

    # Example 06. Using -I option to replace string with input
    printf "server1\nserver2\nserver3\n"

    What I want is =>
        ssh server1 hostname
        ssh server2 hostname
        ssh server3 hostname

    printf "server1\nserver2\nserver3\n" | xargs -I {} ssh {} hostname
      or
      # print the command instead of executing it
    printf "server1\nserver2\nserver3\n" | xargs -I SERVER echo "ssh SERVER hostname"

    # Example 07. Using -n option make the command execute for each argument separately
    echo "one two three" | xargs -n 1 echo
    or
    echo "one two three" | xargs -n 1 echo

    cat servers.txt
        server01
        server02
        server03
    cat servers.txt | xargs -n 1 ping -c 1
        ping -c 1 server01
        ping -c 1 server02
        ping -c 1 server03

    # Example 08. Using -P option to run multiple processes in parallel
    cat servers.txt | xargs -n 1 -P 5 ping -c 1

    # Example 09. Get help on available commands on linux box
    compgen -c | sort -u | xargs -n 1 -P 5 whatis 2>/dev/null

    # find commands related to disk
    compgen -c | sort -u | xargs -n 1 -P 5 whatis 2>/dev/null | grep -i disk

    sudo du -ahb -d 4 /home | sort -gr --key 1 | head -n 20

COMMENTS

