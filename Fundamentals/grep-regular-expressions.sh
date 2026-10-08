:<<'COMMENTS'

Understanding Regular Expressions
----------------------------------

> Regular expressions are text patterns that are used by tools like grep and others.
> Always put your regex between single quotes!
> Don't confuse regular expressions with globbing (shell wildcards)!
> They look like file globbing, but they are not the same.
    > grep 'a*' a*
> For use with specific tools only (grep, sed, awk, vim, etc.)
> See "man 7 regex" for more information.

Example:

# find all files with the work "regex" in them
grep -ri 'regex' /stale-storage/GitHub/Linux-Learning

# find all commands having disk keyword
whatis $(compgen -c) 2> /dev/null | grep -i 'disk'

= ****************************************************************************** =
= ****************************************************************************** =

Using Regular Expressions
----------------------------------
- ^ beginning of line
    grep '^|' myfile.txt

- $ end of line
    grep 'anna$' myfile.txt

- \b end of word
    grep '^lea\b' myfile.txt
    will find lines starting with lea, but not with leanne

- * zero or more of the preceding character
    grep 'n.*x' myfile.txt
    will find lines with n and x with any number of characters in between

- + one or more times (extended regex!)
    grep -E 'bi+t' myfile.txt
    will find lines with bit, biit, biiit, etc.

- ? zero or one time (extended regex!)
    grep -E 'bi?t' myfile.txt
    will find lines with bt, bit

- n\{3\} n exactly 3 times
    grep 'bon\{3\}nen' myfile.txt
    will find bonnnen

- string must be a word
    grep '\banna\b' myfile.txt

- . one character
    grep '\b....\b' myfile.txt
    will find 4 character words

    grep '^.$' myfile.txt
    will find lines with only one character

- either option
    grep -E '(svm|vmx)\b' /proc/cpuinfo

COMMENTS


