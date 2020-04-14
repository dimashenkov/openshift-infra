#!/bin/bash

# Upgrade distribution
yum upgrade -y

# Set timezone
timedatectl set-timezone Europe/Sofia

# Sleep for some time before reboot
# (give some time to Terraform to complete)
sleep 60

reboot
