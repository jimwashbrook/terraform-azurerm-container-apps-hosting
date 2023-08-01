resource "null_resource" "tagging" {
  triggers = {
    resource_id     = azurerm_container_app_environment.container_app_env.id
    tags            = jsonencode(local.tags)
    tagging_command = local.tagging_command
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = local.tagging_command
  }
}
