#!/bin/bash

LOGFILE="/root/userdata.log"

# Register node with RedHat
echo "===> Register with user and pass" >> $LOGFILE
while true
  do subscription-manager register --username ${redhat_user} --password ${redhat_pass} --auto-attach && break
  sleep 5
done >> $LOGFILE 2>&1

# Attach pools to node
echo "===> Attach pool to system" >> $LOGFILE
for i in $(subscription-manager list --available --pool-only); do subscription-manager attach --pool=$i; done >> $LOGFILE 2>&1

# Enable required repositories
echo "===> Enable repositories" >> $LOGFILE
subscription-manager repos \
  --enable="rhel-7-server-rpms" \
  --enable="rhel-7-server-extras-rpms" \
  --enable="rhel-7-server-ose-3.11-rpms" \
  --enable="rhel-7-server-ansible-2.9-rpms" >> $LOGFILE 2>&1

# Set timezone
echo "===> Set system timezone" >> $LOGFILE
timedatectl set-timezone Europe/Sofia >> $LOGFILE 2>&1

# comment line "Defaults    requiretty"
echo "===> Comment out this line in sudoers file" >> $LOGFILE
sed -e '/requiretty/ s/^#*/#/' -i /etc/sudoers >> $LOGFILE 2>&1

# Install the OpenShift Container Platform Package
echo "===> Install packages needed by cluster setup" >> $LOGFILE
yum install -y wget git net-tools bind-utils iptables-services bridge-utils \
  bash-completion kexec-tools sos psacct openshift-ansible cri-o docker >> $LOGFILE 2>&1

# Install additional packages (non mandatory for the project)
echo "===> Install not mandatory packages" >> $LOGFILE
yum install -y vim nc mc wireshark tcpdump strace lynx links sysstat lsof deltarpm \
  mlocate nmap telnet ipmitool screen iotop htop  mtr net-snmp-utils traceroute \
  lshw rsync bzip2 gcc yum-utils >> $LOGFILE 2>&1

# Upgrade distribution
echo "===> Upgrade system (all packages)" >> $LOGFILE
yum upgrade -y >> $LOGFILE 2>&1

# Add Ansible beautifier in the config
echo "===> Add ansible beautifier" >> $LOGFILE
sed -i '/^log_path.*/a stdout_callback = yaml' /usr/share/ansible/openshift-ansible/ansible.cfg >> $LOGFILE 2>&1
sed -i '/^stdout_callback.*/a bin_ansible_callbacks = True' /usr/share/ansible/openshift-ansible/ansible.cfg >> $LOGFILE 2>&1

# # Wait before reboot (give time to Terraform to complete)
# echo "===> Sleep before restart" >> $LOGFILE
# sleep 60 >> $LOGFILE 2>&1

echo "===> Reboot system" >> $LOGFILE
reboot
