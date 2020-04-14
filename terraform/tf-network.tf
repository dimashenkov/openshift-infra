#===============================================================================
# Infrastructure VPC
resource "aws_vpc" "osc-net-vpc" {
  cidr_block           = var.cluster-vpc-cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "osc-net-vpc"
  }
}

#===============================================================================
# VPC subnets settings
resource "aws_subnet" "osc-net-subnet" {
  vpc_id            = aws_vpc.osc-net-vpc.id
  cidr_block        = var.cluster-subnet-cidr
  availability_zone = "${var.aws-region}a"
  tags = {
    Name = "osc-net-subnet"
  }
}

resource "aws_internet_gateway" "osc-net-gateway" {
  vpc_id = aws_vpc.osc-net-vpc.id
  tags = {
    Name = "osc-net-gateway"
  }
}

resource "aws_route_table" "osc-net-routingtable" {
  vpc_id = aws_vpc.osc-net-vpc.id
  route {
    cidr_block = var.world-open-cidr
    gateway_id = aws_internet_gateway.osc-net-gateway.id
  }
  tags = {
    Name = "osc-net-routingtable"
  }
}

resource "aws_route_table_association" "subnet-association" {
  subnet_id      = aws_subnet.osc-net-subnet.id
  route_table_id = aws_route_table.osc-net-routingtable.id
}

#===============================================================================
# Define security groups
resource "aws_security_group" "osc-net-sg-in-ssh" {
  name        = "osc-net-sg-in-ssh"
  vpc_id      = aws_vpc.osc-net-vpc.id
  description = "Open SSH traffic to nodes"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.world-open-cidr]
  }
}

resource "aws_security_group" "osc-net-sg-in-master" {
  name   = "osc-net-sg-in-master"
  vpc_id = aws_vpc.osc-net-vpc.id
  ingress {
    description = "Open all traffic (TCP/UDP) between nodes"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cluster-subnet-cidr]
  }
  ingress {
    description = "Required for node hosts to communicate to the master API, for node hosts to post back status, to receive tasks, and so on."
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.world-open-cidr]
  }
  ingress {
    description = "Required for node hosts to communicate to the master API, for node hosts to post back status, to receive tasks, and so on."
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.world-open-cidr]
  }
  ingress {
    description = "For use by the OpenShift Enterprise web console, shared with the API server."
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = [var.world-open-cidr]
  }
  ingress {
    description = "For use by the Kubelet. Required to be externally open on nodes."
    from_port   = 24224
    to_port     = 24224
    protocol    = "tcp"
    cidr_blocks = [var.world-open-cidr]
  }
  ingress {
    description = "For use by the Kubelet. Required to be externally open on nodes."
    from_port   = 24224
    to_port     = 24224
    protocol    = "udp"
    cidr_blocks = [var.world-open-cidr]
  }
}

resource "aws_security_group" "osc-net-sg-in-worker" {
  name   = "osc-net-sg-in-worker"
  vpc_id = aws_vpc.osc-net-vpc.id
  ingress {
    description = "Open all traffic (TCP/UDP) between nodes"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cluster-subnet-cidr]
  }
  ingress {
    description = "For use by the Kubelet. Required to be externally open on nodes."
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = [var.world-open-cidr]
  }
}

resource "aws_security_group" "osc-net-sg-out-all" {
  name        = "osc-net-sg-out-all"
  vpc_id      = aws_vpc.osc-net-vpc.id
  description = "Allow all outgoing traffic"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.world-open-cidr]
  }
}
