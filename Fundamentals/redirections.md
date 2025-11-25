# [Redirections in Linux with Examples](https://linuxopsys.com/redirections-in-linux-with-examples)

## Introduction

Redirection operators let you manipulate input and output streams. 
These will enable you to send the output of a command to a file, or use the contents of a file as input for a command.

## Using the Append Redirection Operator

We can use the append redirection (or the output redirection) to write directly into a file without using a text editor.
To achieve this trick you can use the cat command and the >> operator just as so:

$ cat >> quotes.txt
```
The arrow shot by the archer may or may not kill a single person.
But stratagems devised by wise men can kill even babes in the womb.
```

When you've finished typing, just hit *`ctrl+d`* to exit the mode and save the file.

## Using the Input Redirection Operator

| It's important to remember that only commands that generally receive input from the keyboard can get their input from a file.

```
grep -w arrow < quotes.txt
```

### A valid use case for input redirection is with `tr` utility that does not have input function of reading files

```
# get a file with employees and mobile numbers
cat ./employees.txt
Ajay Dwivedi: 986812345
Saanvi Dwivedi: 9712341234

# using tr, remove the mobile numbers before sharing
tr -d [:digit:] < employees.txt

```

## Redirecting Output and Errors into a Single File

```
cat quotes.txt idontexist &> output_and_error
cat quotes.txt idontexist 2>&1 output_and_error
```


