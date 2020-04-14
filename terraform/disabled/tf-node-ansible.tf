#===============================================================================
# ansible instance
resource "aws_instance" "osc-node-ansible" {
  ami           = var.ansible-node-ami
  instance_type = var.ansible-node-instance
  tags = {
    Name = "osc-node-ansible"
  }
  volume_tags = {
    Name = "osc-vol-ansible"
  }
  timeouts {
    create = "60m"
    delete = "2h"
  }
  user_data                   = file("./scripts/infra_install_ansible.sh")
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.osc-net-subnet.id
  vpc_security_group_ids      = [aws_security_group.osc-net-sg-in-ssh.id, aws_security_group.osc-net-sg-out-all.id]
  key_name                    = aws_key_pair.osc-keypair.key_name
  # Wait master and workers to be set before Ansible node
  # in order to get node internal IPs for inventory file
  depends_on = [
    aws_internet_gateway.osc-net-gateway,
    aws_instance.osc-node-master,
    aws_instance.osc-node-worker,
  ]
}

resource "aws_eip" "osc-node-ansible-ip" {
  instance = aws_instance.osc-node-ansible.id
  vpc      = true
}

resource "null_resource" "osc-check-ansibles" {
  depends_on = [aws_eip.osc-node-ansible-ip]
  provisioner "local-exec" {
    command = "./scripts/infra_copy_ssh.sh ${aws_eip.osc-node-ansible-ip.public_dns} ${var.ssh-private-key}"
  }
}

#===============================================================================
# Outputs
output "output_osc-node-ansible_private-networking" {
  value       = map(aws_instance.osc-node-ansible.private_ip, aws_instance.osc-node-ansible.private_dns)
  description = "ansible node private networking"
}

output "output_osc-node-ansible_public-networking" {
  value       = map(aws_eip.osc-node-ansible-ip.public_ip, aws_eip.osc-node-ansible-ip.public_dns)
  description = "ansible node public networking"
}
