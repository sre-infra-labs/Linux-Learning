# Error/Fix: This system is registered with an entitlement server, but is not receiving updates. You can use subscription-manager to assign subscriptions
## Fix
```
sudo subscription-manager clean

sudo subscription-manager register --username="<your_redhat_username>" --password="<your_redhat_password>"

sudo subscription-manager attach --auto

sudo subscription-manager status
sudo dnf clean all
sudo dnf install consul
```

# Error/Fix: Space issue due to large log file

```
# create a log file on mount point to consume all space
dd if=/dev/zero of=/path/to/mount/test.log bs=1M status=progress

# create a log file of 1 gb size on mount point
dd if=/dev/zero of=/path/to/mount/test.log bs=1M status=progress count=1000

# get filesystem space usage
df -hP

# get directory size info
du / 2> /dev/null | sort -rn | head

# get files on particular directory
ls -lh /mnt/vdd

# deleting the file may not really remove it if its in use

# Empty the file if allowed
sudo sh -c 'cat /dev/null > /mnt/vdd/test.log'

# Remove file, and check if its still in use
rm /mnt/vdd/test.log
lsof | grep deleted


```

# Error/Fix: Unmount hung device

```bash
# find what is using the mount point
lsof +D /mnt/vdd

# kill all processes using the mount point
fuser -vm /mnt/vdd
fuser -k -9 -m /mnt/vdd

# unmount the device
umount /mnt/vdd

# signal intent of unmounting. So no new processes can access the mount point
umount -l /mnt/vdd

```

