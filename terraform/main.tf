#===============================================================================
# Set provider
provider "aws" {
  region = var.aws-region
}

#===============================================================================
# Create AWS keypair to be used for instances
resource "aws_key_pair" "osc-keypair" {
  key_name   = "osc-keypair"
  public_key = file(var.ssh-public-key)
}

# # FOR FURTHER USE
# resource "null_resource" "osc-cleanup" {
#   # Execute cleanup on destroy
#   provisioner "local-exec" {
#     when    = destroy
#     command = "./scripts/infra_cleanup.sh"
#   }
# }
