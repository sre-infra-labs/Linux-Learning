:<<'COMMENTS'

Installing Softwares from Source Packages
-----------------------------------------

-> Softwares can be delivered in a compressed tar ball (an archive that is compressed with the "tar" utility)

-> This may contain a setup script, or just source files

-> To get this on your computer, you need to install it, which often involves compiling

-> Compiling makes software ready to run on a specific platform

-> The disadvantage: There is no central registration on your machine of software
    that was installed this way.


Understanding Software Packages
-------------------------------

-> A Package is a tar ball with something in addition
    -> A script to copy files to the right location
    -> A database to keep track of what is installed

-> Packages typically focus on the software they want to install, and use
    dependencies for related software packages

-> That means the dependency needs to be installed before you can install the package

-> With a result that can be a real dependency hell

-> RPM is the standard package format in Red Hat, DEB is the standard
    package format in Ubuntu


Understanding Libraries
-----------------------------

-> Libraries make working with software easier

-> They provide common functionality that may be used by multiple packages

-> Some libraries are specific

-> Some libraries are more generic

-> And there is libc, the C-Library that provides all of the common functions
    in the Linux operating system

-> When installing software packages, libraries are installed as dependencies


Working with Sofware Managers
---------------------------------

-> Software Managers were developed to fix the dependency problems

-> They do so by working with repositories

-> Repositories typically are on-line resources where packages are stored

-> Before installing a package, the software manager analyzes the dependencies and will
    try to fetch the dependencies from the repositories

-> Repositories are provided by the Linux distribution, or software vendors,
    or you may create your own

-> Common software managers are "yum/dnf" and "apt"

# Enable extra repos in rhel
sudo dnf install \
https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm

sudo dnf install snapd -y
sudo dnf install tldr -y




Managing Packages with yum/dnf
---------------------------------

-> yum is used in older versions of Red Hat, the yum backend has recently
    been replaced with dnf

-> "dnf" is the preferred tool in current RHEL versions, but as of now "dnf"
    and "yum" are basically the same
        -> Both commands are a symbolic link to the same binary

-> "dnf" uses repositories that are in /etc/yum.repos.d

-> The command was written to be intuitive
    -> dnf install
    -> dnf search
    -> dnf remove

-> "dnf" allows working with package groups to make installation of specific
    functionality easy
        -> dnf group list
        -> dnf group install

-> Yum Modules provide a way to install different versions of packages,
    including all of the required dependencies
    -> yum module install container-tools

-> Finding the right package may be a challenge, but there's "dnf provides" to
    fix that: "dnf provides */selinux"

-> And "dnf history" allows you to undo changes after installing packages


Understanding apt
---------------------------

-> "apt" is the Ubuntu-equivalent of "yum"

-> "apt" is a newer replacement of older utilities like "apt-cache" and "apt-get"

-> Like yum, apt was developed to work with packages in an intuitive way

-> "apt" repositories are defined in /etc/apt/sources.list

-> Use "sudo apt search filename" to search for packages containing a specific file

-> First, make sure that the local list of packages is updated to the most recent version
    of packages using apt update

-> Use "apt search" to search for packages

-> Use "apt list --installed" to get installed packages
sudo apt list --installed | grep cow

-> Use "apt install" to remove packages
    -> If a package contains a service, it will be started and enabled automatically

-> Use "apt upgrade" to upgrade packages

-> Sometimes packages are installed as dependencies, but no longer required.
    Use "apt autoremove" to remove them

-> Use "sudo apt-cache search filename" to search for packages containing a specific file
sudo apt-cache search nmap


Understanding rpm
---------------------------

-> The "rpm" command should not be used for package installation anymore

-> It is still useful to work with the RPM database, and allows you to do package queries
    -> rpm -qf /my/file
        will tell you which package a file is from
    -> rpm -ql mypackage
        queries the database to list package contents

-> To query the package file instead of the package contents, add a "p" to the options
    -> rpm -qpc mypackage.rpm
        lists configuration files in a downloaded package file
    -> rpm -qp --scripts mypackage.rpm
        shows scripts that may be present in a package


COMMENTS

# install from package
sudo rpm -ivh emacs-auctex-12.3-2.el9.noarch.rpm

# extract help of rpm for "ivh" options
rpm --help | grep -E '^\s*-([ivh])'

# Display shared library dependencies of a binary using "ldd"
which passwd
whatis ldd

ldd $(which passwd)

    :<<'COMMAND_OUTPUT'
|------------$ ldd $(which passwd)
        linux-vdso.so.1 (0x00007fff441e6000)
        libpam.so.0 => /lib/x86_64-linux-gnu/libpam.so.0 (0x00007d15b06e6000)
        libpam_misc.so.0 => /lib/x86_64-linux-gnu/libpam_misc.so.0 (0x00007d15b06df000)
        libaudit.so.1 => /lib/x86_64-linux-gnu/libaudit.so.1 (0x00007d15b06b1000)
        libselinux.so.1 => /lib/x86_64-linux-gnu/libselinux.so.1 (0x00007d15b0684000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007d15b0400000)
        libcap-ng.so.0 => /lib/x86_64-linux-gnu/libcap-ng.so.0 (0x00007d15b067a000)
        libpcre2-8.so.0 => /lib/x86_64-linux-gnu/libpcre2-8.so.0 (0x00007d15b0366000)
        /lib64/ld-linux-x86-64.so.2 (0x00007d15b072f000)
COMMAND_OUTPUT

sudo yum search nmap
sudo yum provides */nmap

# Search package through manager
sudo yum search seinfo

# If normal search does not work, then try search in package files
sudo yum provides */seinfo
sudo yum provides */seinfo

# go get more info about package
sudo yum info setools-console

sudo yum history
sudo dnf history undo 13
sudo dnf history redo 13

sudo yum upgrade

# get groups of packages
sudo yum group list

# install group of packages
sudo yum group install "system Tools"

# find the package "ifconfig" file is part of
sudo rpm -qf $(which ifconfig)
    # net-tools-2.0-0.71.20160912git.fc41.x86_64

# find all files for a package
sudo rpm -ql net-tools | grep bin
    :<<'COMMAND_OUTPUT'
    /usr/bin/netstat
    /usr/sbin/arp
    /usr/sbin/ether-wake
    /usr/sbin/ifconfig
    /usr/sbin/ipmaddr
    /usr/sbin/iptunnel
    /usr/sbin/mii-diag
    /usr/sbin/mii-tool
    /usr/sbin/nameif
    /usr/sbin/plipconfig
    /usr/sbin/route
    /usr/sbin/slattach
COMMAND_OUTPUT

# download a sample external rpm package, and check configuration files in it
curl https://rpmfind.net/linux/centos-stream/10-stream/AppStream/x86_64/os/Packages/virtio-win-1.9.44-1.el10.noarch.rpm --output ./Downloads/virtio-win-1.9.44-1.el10.noarch.rpm
ls ./Downloads/*rpm
rpm -qpc ./Downloads/virtio-win-1.9.44-1.el10.noarch.rpm

# check entire content
rpm -qpl ./Downloads/virtio-win-1.9.44-1.el10.noarch.rpm

# check for any installation script in package
rpm -qp --scripts ./Downloads/virtio-win-1.9.44-1.el10.noarch.rpm

# what updates are available for installed packages
sudo dnf list updates
sudo apt list --upgradable

