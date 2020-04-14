#!/bin/bash

HOSTADDR=$1
HOSTKEY=$2
SLEEPTIME=5

while true
  do scp -o StrictHostKeyChecking=no -i ${HOSTKEY} ~/.ssh/osc-key ec2-user@${HOSTADDR}:/home/ec2-user/.ssh/id_rsa > /dev/null 2>&1&& \
  scp -o StrictHostKeyChecking=no -i ${HOSTKEY} ~/.ssh/osc-key.pub ec2-user@${HOSTADDR}:/home/ec2-user/.ssh/id_rsa.pub > /dev/null 2>&1&& \
  echo "SSH keys copied to '${HOSTADDR}'. Continue" && \
  break
    if [ "$?" != "0" ]; then
      echo "Address '${HOSTADDR}' still not ready for SSH connection. Sleep for ${SLEEPTIME} seconds..."
    fi
  sleep ${SLEEPTIME}
done

# Some check varians are below, no need to be used

# while true
#   do ssh -o StrictHostKeyChecking=no -q ec2-user@${HOSTADDR} -i ${HOSTKEY} exit > /dev/null 2>&1 && \
#   echo "Address '${HOSTADDR}' is now ready for SSH connection. Copy SSH keys" && \
#   break
#     if [ "$?" != "0" ]; then
#       echo "Address '${HOSTADDR}' still not ready for SSH connection. Sleep for ${SLEEPTIME} seconds..."
#     fi
#   sleep ${SLEEPTIME}
# done

# HOSTADDR="abv.bge"
# SLEEPTIME=5
# while true
#   do ping -c1 ${HOSTADDR} > /dev/null 2>&1 && echo "Address '${HOSTADDR}' is now ready. Continue" && break
#     if [ "$?" != "0" ]; then
#       echo "Address '${HOSTADDR}' still not ready. Sleep for ${SLEEPTIME} seconds..."
#     fi
#   sleep ${SLEEPTIME}
# done
