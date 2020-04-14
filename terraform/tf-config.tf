#===============================================================================
# Set terraform state storage
terraform {
  backend "s3" {
    bucket = "tf-state-osc"
    key    = "./terraform-stage.tfstate"
    region = "eu-central-1"
  }
}

#===============================================================================
# Variables read from ENVIRONMENT
variable "rhel_user" {}
variable "rhel_pass" {}

#===============================================================================
# Global config variables
variable "ssh-private-key" {
  description = "Private SSH key used for connection to nodes"
  type        = string
  default     = "~/.ssh/osc-key"
}

variable "ssh-public-key" {
  description = "Public SSH key used for connection to nodes"
  type        = string
  default     = "~/.ssh/osc-key.pub"
}

variable "aws-region" {
  description = "Region where to deploy the cluster"
  type        = string
  default     = "eu-central-1"
}

#===============================================================================
# Network config variables
variable "cluster-vpc-cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "cluster-subnet-cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.10.0/24"
}

variable "world-open-cidr" {
  description = "World open CIDR block"
  type        = string
  default     = "0.0.0.0/0"
}

#===============================================================================
# Openshift master node settings
variable "openshift-master-node-ami" {
  description = "Master node AMI ID"
  type        = string
  # # Red Hat Enterprise Linux 8 (HVM), SSD Volume Type
  # default     = "ami-0badcc5b522737046"
  # RHEL-7.7_HVM-20191028-x86_64-1-Hourly2-GP2
  default = "ami-05798e9b15f285b27"
}

variable "openshift-master-node-instance" {
  description = "Master node instance type"
  type        = string
  default     = "t2.xlarge"
}

variable "openshift-master-node-root-block-device-size" {
  description = "Master node root disk size in GB"
  type        = number
  default     = 50
}

variable "openshift-master-node-root-block-device-type" {
  description = "Master node root disk type (standard, gp2, io1, sc1, or st1)"
  type        = string
  default     = "gp2"
}

variable "openshift-master-node-count" {
  description = "Master nodes count"
  type        = number
  default     = 1
}

variable "ip-prefix-master" {
  description = "Master nodes IP prefix"
  type        = string
  default     = "10.0.10.1"
}

#===============================================================================
# Openshift worker node settings
variable "openshift-worker-node-ami" {
  description = "Worker node AMI ID"
  type        = string
  # # Red Hat Enterprise Linux 8 (HVM), SSD Volume Type
  # default     = "ami-0badcc5b522737046"
  # RHEL-7.7_HVM-20191028-x86_64-1-Hourly2-GP2
  default = "ami-05798e9b15f285b27"
}

variable "openshift-worker-node-instance" {
  description = "Worker node instance type"
  type        = string
  default     = "t2.large"
}

variable "openshift-worker-node-root-block-device-size" {
  description = "Worker node root disk size in GB"
  type        = number
  default     = 20
}

variable "openshift-worker-node-root-block-device-type" {
  description = "Worker node root disk type (standard, gp2, io1, sc1, or st1)"
  type        = string
  default     = "gp2"
}

variable "openshift-worker-node-ebs-device-size" {
  description = "Worker node EBS disk size in GB (for GlusterFS)"
  type        = number
  default     = 10
}

variable "openshift-worker-node-ebs-device-type" {
  description = "Worker node EBS disk type (standard, gp2, io1, sc1, or st1)"
  type        = string
  default     = "standard"
}

variable "openshift-worker-node-count" {
  description = "Worker nodes count"
  type        = number
  default     = 4
}

variable "ip-prefix-worker" {
  description = "Worker nodes IP prefix"
  type        = string
  default     = "10.0.10.2"
}

#===============================================================================
# Ansible node settings
variable "ansible-node-ami" {
  description = "Ansible node AMI ID"
  type        = string
  # Amazon Linux AMI 2018.03.0 (HVM), SSD Volume Type
  default = "ami-0df53967dc6eab09d"
}

variable "ansible-node-instance" {
  description = "Ansible node instance type"
  type        = string
  default     = "t2.micro"
}
