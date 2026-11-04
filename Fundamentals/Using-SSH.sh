:<<'COMMENTS'

Using the SSH Client
--------------------

-> When first logging in to an SSH server, the server host key
    is cached in the file ~/.ssh/known_hosts

-> While connecting to a host, the key is checked, and if it doesn't match connection is refused

-> To connect to a non default port, use "-p (ssh)" or "-P (scp)"


Configuring Key-based SSH Login
-------------------------------------

-> By default, SSH access is based on username and password

-> For enhanced security, consider using key-based access

-> The user creates a key pair. Next, public key is copied over to the SSH host
    where it is stored in ~/.ssh/authorized_keys

-> For additional protection, the key may be protected with a passphrase
    -> ssh-keygen
    -> ssh-copy-id sshserver

-> To add protection to SSH keys, they should be protected with a passphrase

-> Entering a passphrase on initialization of every session is annoying

-> Use "ssh-agent /bin/bash" to run the SSH agent, which can cache the passphrase for the session duration
ssh-agent /bin/bash
ssh-add

-> Use "ssh-add" to add the current shell to the agent: you'll enter
    the passphrase once


SSH Jumping (-J)
----------------------------------------------

-> SSH Jumping (-J) is used when you want to run an interactive terminal shell on a deeply hidden server by routing your command line through an intermediate server (a jump host).

# single jump host
ssh -J user1@jump-host.com user2@internal-server.local

# multiple jump hosts
ssh -J user1@jump1.com,user2@jump2.com user3@internal-server.local


The -J flag tells SSH to automatically establish a secure proxy through jump-host.com. 
Instead of making you manually log into the jump host and then run another SSH command from there, 
your laptop establishes an end-to-end encrypted session directly to the internal-server.local via the proxy. 
The jump host cannot inspect your traffic.


SSH Tunneling - Local Port Forwarding (-L)
----------------------------------------------

-> Use this when you want to bring a remote service to your laptop.

ssh -N -f -L 8080:localhost:5432 user@remote-server.com

• -L 8080:localhost:5432 tells your laptop to open up a listening port at localhost:8080. Any traffic sent there gets bundled, encrypted, and sent to remote-server.com, which decrypts it and drops it off locally at its own port 5432.
• -N tells SSH not to open a command line terminal (you only want the tunnel).
• -f sends the SSH process to the background so your terminal remains free.


SSH Tunneling - Remote Port Forwarding (-R)
----------------------------------------------

-> Use this when you want to expose a local service running on your laptop to the outside world.

ssh -N -f -R 9000:localhost:3000 user@public-server.com

• -R 9000:localhost:3000 tells the public-server.com to open a listening port at 9000. 
  Any traffic arriving at the public server on port 9000 travels backward through the established SSH tunnel to your laptop's port 3000.


SSH Tunneling - Dynamic Port Forwarding (-D)
----------------------------------------------

-> Use this when you want to create a SOCKS proxy.
    Instead of mapping one local port to one specific remote port, your SSH connection acts as a flexible router for all sorts of destinations through the remote server.

ssh -N -f -D 1080 user@remote-server.com

• -D 1080 turns your laptop's port 1080 into a SOCKS proxy gateway


Combining Jumping and Tunneling
----------------------------------------------

ssh -N -f -J user1@jump-host.com -L 8080:localhost:5432 user2@internal-server.local


Simplify Using ~/.ssh/config
----------------------------------------------

# Configuration for jumping
Host internal-box
    HostName internal-server.local
    User user2
    ProxyJump user1@jump-host.com

# Configuration for a persistent database tunnel
Host db-tunnel
    HostName jump-host.com
    User user1
    LocalForward 8080 internal-db.local:5432
    ExitOnForwardFailure yes
    ServerAliveInterval 30




COMMENTS

# ssh saanvi@msi



