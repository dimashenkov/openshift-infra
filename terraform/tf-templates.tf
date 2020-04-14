#===============================================================================
# Render user_data template
data "template_file" "user_data" {
  template = file("./templates/user_data.tpl")
  vars = {
    redhat_user = var.rhel_user
    redhat_pass = var.rhel_pass
  }
}
