#===============================================================================
# master instances
resource "aws_instance" "osc-node-master" {
  ami           = var.openshift-master-node-ami
  instance_type = var.openshift-master-node-instance
  count         = var.openshift-master-node-count
  tags = {
    Name     = "osc-node-master-${count.index + 1}"
    nodetype = "master"
  }
  volume_tags = {
    Name = "osc-vol-master-${count.index + 1}"
  }
  root_block_device {
    volume_size = var.openshift-master-node-root-block-device-size
    volume_type = var.openshift-master-node-root-block-device-type
  }
  timeouts {
    create = "60m"
    delete = "2h"
  }
  user_data                   = data.template_file.user_data.rendered
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.osc-net-subnet.id
  private_ip                  = "${var.ip-prefix-master}${count.index + 1}"
  vpc_security_group_ids      = [aws_security_group.osc-net-sg-in-ssh.id, aws_security_group.osc-net-sg-in-master.id, aws_security_group.osc-net-sg-out-all.id]
  key_name                    = aws_key_pair.osc-keypair.key_name
  depends_on                  = [aws_internet_gateway.osc-net-gateway]
}

resource "aws_eip" "osc-node-master-ip" {
  count    = var.openshift-master-node-count
  instance = aws_instance.osc-node-master[count.index].id
  vpc      = true
}

resource "null_resource" "osc-check-masters" {
  depends_on = [aws_eip.osc-node-master-ip]
  provisioner "local-exec" {
    command = "for i in ${join(" ", aws_eip.osc-node-master-ip.*.public_dns)}; do ./scripts/infra_copy_ssh.sh $i ${var.ssh-private-key}; done"
  }
}

#===============================================================================
# Outputs
output "output_osc-node-master_private-networking" {
  value       = zipmap(aws_instance.osc-node-master.*.private_ip, aws_instance.osc-node-master.*.private_dns)
  description = "master node private networking"
}

output "output_osc-node-master_public-networking" {
  value       = zipmap(aws_eip.osc-node-master-ip.*.public_ip, aws_eip.osc-node-master-ip.*.public_dns)
  description = "master node public networking"
}
