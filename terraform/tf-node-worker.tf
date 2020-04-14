#===============================================================================
# worker instances
resource "aws_instance" "osc-node-worker" {
  ami           = var.openshift-worker-node-ami
  instance_type = var.openshift-worker-node-instance
  count         = var.openshift-worker-node-count
  tags = {
    Name     = "osc-node-worker-${count.index + 1}"
    nodetype = "worker"
  }
  volume_tags = {
    Name = "osc-vol-worker-${count.index + 1}"
  }
  root_block_device {
    volume_size           = var.openshift-worker-node-root-block-device-size
    volume_type           = var.openshift-worker-node-root-block-device-type
    delete_on_termination = true
  }
  ebs_block_device {
    device_name           = "/dev/xvdb"
    volume_size           = var.openshift-worker-node-ebs-device-size
    volume_type           = var.openshift-worker-node-ebs-device-type
    delete_on_termination = true
  }
  timeouts {
    create = "60m"
    delete = "2h"
  }
  user_data                   = data.template_file.user_data.rendered
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.osc-net-subnet.id
  private_ip                  = "${var.ip-prefix-worker}${count.index + 1}"
  vpc_security_group_ids      = [aws_security_group.osc-net-sg-in-ssh.id, aws_security_group.osc-net-sg-in-worker.id, aws_security_group.osc-net-sg-out-all.id]
  key_name                    = aws_key_pair.osc-keypair.key_name
  depends_on                  = [aws_internet_gateway.osc-net-gateway]
}

resource "aws_eip" "osc-node-worker-ip" {
  count    = var.openshift-worker-node-count
  instance = aws_instance.osc-node-worker[count.index].id
  vpc      = true
}

resource "null_resource" "osc-check-workers" {
  depends_on = [aws_eip.osc-node-worker-ip]
  provisioner "local-exec" {
    command = "for i in ${join(" ", aws_eip.osc-node-worker-ip.*.public_dns)}; do ./scripts/infra_copy_ssh.sh $i ${var.ssh-private-key}; done"
  }
}

#===============================================================================
# Outputs
output "output_osc-node-worker_private-networking" {
  value       = zipmap(aws_instance.osc-node-worker.*.private_ip, aws_instance.osc-node-worker.*.private_dns)
  description = "worker node private networking"
}

output "output_osc-node-worker_public-networking" {
  value       = zipmap(aws_eip.osc-node-worker-ip.*.public_ip, aws_eip.osc-node-worker-ip.*.public_dns)
  description = "worker node public networking"
}
