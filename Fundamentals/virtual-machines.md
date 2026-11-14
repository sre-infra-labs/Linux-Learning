# Working with Virtual Machines

https://www.youtube.com/live/OPStJ52bvG0?si=nbGcv5TIqCcJCmFP

# Integration multi-factor authentication - /stale-storage/GitHub/Linux-Learning/Fresh-Linux-OS-Setup/cockpit-2-step-authentication.md

# KVM & Virt Viewer
  > https://linuxcapable.com/how-to-install-kvm-on-ubuntu-linux/
  > https://ubuntu.com/server/docs/virtualization-virt-tools
  > https://docs.netapp.com/us-en/netapp-solutions-virtualization/kvm/kvm-overview.html#overview-of-components

  > Reattach virtual machines
  > Ensure network ip in subnet 192.168.100.x & 192.168.200.x
  > Reboot after install

```bash
# RHEL
  sudo dnf group info virtualization
  sudo dnf install -y @virtualization

  systemctl is-enabled virtqemud.socket virtnetworkd.socket virtstoraged.socket libvirtd.socket libvirtd.service
  systemctl is-active virtqemud.socket virtnetworkd.socket virtstoraged.socket

  sudo systemctl start sockets.target
  systemctl is-active virtnetworkd.socket virtstoraged.socket virtnodedevd.socket virtsecretd.socket

  sudo virt-host-validate qemu
```


# Save VM Config for future Restore.

```bash
  # Scriptout Path - SqlServerLab/kvm-vms-config/*.xml
  # https://schh.medium.com/backup-and-restore-kvm-vms-21c049e707c1
cd /stale-storage/GitHub/SqlServerLab/kvm-vms-config

VM_LIST=$(virsh list --all | awk 'NR > 2 {print $2}')

for VM in $VM_LIST; do
  echo
  echo "Working on __ $VM __"
  virsh dumpxml $VM > "$VM.xml"
done

```

# Restore VM from Config file

```bash
  # Scriptout Path - SqlServerLab/kvm-vms-config/*.xml
  # https://schh.medium.com/backup-and-restore-kvm-vms-21c049e707c1
cd /stale-storage/GitHub/SqlServerLab/kvm-vms-config

VM_LIST=$(ls *.xml | sed 's/\.xml$//' | grep -v '^VM_LIST$')

for VM in $VM_LIST; do
  echo
  echo "Working on __ $VM __"
  virsh define --file "$VM.xml"
done

```

# General Commands

```bash
# get running vms
virsh list

# get all vms
virsh list --all

# Start/reboot/reset/shutdown/destroy/suspend/resume a domain:
virsh start|reboot|reset|shutdown|destroy|suspend|resume domain

# auto reboot vm when hypervisor reboots
virsh autorestart sqlred

```

# Create kvm VMs from existing vm

```bash
# Clone the VMs
virt-clone --original KubeMaster --name KubeNode1 --file /vm-os/KubeNode1.qcow2
virt-clone --original KubeMaster --name KubeNode2 --file /vm-os/KubeNode2.qcow2
virt-clone --original KubeMaster --name KubeNode3 --file /vm-os/KubeNode3.qcow2

# Reset OS Identities
sudo hostnamectl set-hostname KubeNode1
sudo truncate -s 0 /etc/machine-id
sudo systemd-machine-id-setup
sudo rm -f /etc/ssh/ssh_host_*
sudo ssh-keygen -A
sudo reboot


# Start Your Cluster VMs
virsh start KubeMaster
virsh start KubeNode1
virsh start KubeNode2
virsh start KubeNode3

```



