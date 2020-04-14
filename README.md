# DevOps Exam Deployment

## Prerequisites
x. Software prerequisites. Following applications need to be installed and configured on deployment laptop prior the deployment
- git
- Terraform
- Red Hat account with valid subscriptions (remove active subscriptions related to cluster nodes!)
  - RHEL subscription
  - OpenShift Container Platform Subscription
x. Specific requirements found during deployment tests:
- 8GB RAM per workers
- 16GB RAM per masters
- 40GB /var per masters
- GlusterFS nodes count must be >= 3

## Prepare SSH key pair for node connection
x. Generate SSH keypair for connection to EC2 instances
```
# ssh-keygen -t rsa -C "ocs@openshift.local" -f ~/.ssh/osc-key
```
- connect to node using
```
# ssh -i ~/.ssh/osc-key ec2-user@[public-machine-hostname]
```

## Deployment steps
x. Export environment variables needed by Terraform
```
# export AWS_ACCESS_KEY_ID=[your access key id]
# export AWS_SECRET_ACCESS_KEY=[your secret access key]
# export TF_VAR_rhel_user=[your RedHat account username]
# export TF_VAR_rhel_pass=[your RedHat account password]
```

x. Clone Infrastructure repository
```
# mkdir -p ~/work/openshift-cluster
# git clone git@git.epam.com:Peter_Tsonkov/osc-infra.git
```

x. Deploy project \
__NOTE:__ Terraform will save state file in S3 bucket \
__WARNING:__ After infrastructure provisioning eac hode will be upgraded and will be restarted!
```
# cd ~/work/openshift-cluster/osc-web-infra/terraform
# terraform plan
# terraform apply
```

## Deployment flow

### STAGE_1 Infrastructure deployment
x. Terraform will do:
- Create SSH keypair for authenticate against EC2 nodes
- Create infrastructure network
  - VPC
  - subnet
  - default gateway
  - routing table
  - security group
- Deploy EC2 instance for cluster master
- Deploy EC2 instance for cluster workers

### STAGE_2 Cluster deployment
x. Prepare Ansible inventory
- Copy inventory file to master node (execute on host)
```
scp -o StrictHostKeyChecking=no -i ~/.ssh/osc-key ./templates/osc-inventory ec2-user@[master-public-ip]:/home/ec2-user/osc-inventory
```
- set correct values for box brackets (execute on master node)
```
vim /home/ec2-user/osc-inventory
```
x. Login to master and execute Ansible playbooks (run in screen session) to install prerequisites and to deploy the cluster
- Check USER_DATA installation status for nodes. Last state is "Reboot"
```
for i in 10.0.10.11 10.0.10.21 10.0.10.22 10.0.10.23 10.0.10.24
  do echo $i
  ssh -o StrictHostKeyChecking=no $i 'sudo grep -i "===>" /root/userdata.log'
done
```
- Execute deployment steps
```
# screen -S p1
# cd /usr/share/ansible/openshift-ansible/
# ansible-playbook -i ~/osc-inventory playbooks/prerequisites.yml -v
# ansible-playbook -i ~/osc-inventory playbooks/deploy_cluster.yml -v
```

### Interact with cluster
TBD

### Test and confirm
TBD

# TODO (improvements)
- GlusterFS static provisioning (https://docs.openshift.com/container-platform/3.11/install_config/persistent_storage/persistent_storage_glusterfs.html#provisioning-static)
- create glusterfs volume
```
$ mkdir -p /mnt/glusterfs/myVol1
$ mount -t glusterfs 192.168.122.221:/myVol1 /mnt/glusterfs/myVol1
```
- use multiple user_data files (https://stackoverflow.com/questions/43642308/multiple-user-data-file-use-in-terraform)
- make if-else in user_data depend on node type (master or worker)
