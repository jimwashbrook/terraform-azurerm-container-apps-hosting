resource "azurerm_container_app_environment" "container_app_env" {
  name                           = "${local.resource_prefix}containerapp"
  location                       = local.resource_group.location
  resource_group_name            = local.resource_group.name
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.container_app.id
  infrastructure_subnet_id       = local.launch_in_vnet ? azurerm_subnet.container_apps_infra_subnet[0].id : null
  internal_load_balancer_enabled = local.environment_accessibility_level == "internal" ? true : false

  tags = local.tags
}

resource "azurerm_container_app" "container_apps" {
  for_each = toset(concat(
    ["main"],
    local.enable_worker_container ? ["worker"] : [],
  ))

  name = "${join("-", [
    local.resource_prefix,
    local.image_name,
  ])}${each.value == "worker" ? "-worker" : ""}"
  container_app_environment_id = azurerm_container_app_environment.container_app_env.id
  resource_group_name          = local.resource_group.name
  revision_mode                = "Single"

  dynamic "ingress" {
    for_each = each.value == "main" ? [1] : []

    content {
      external_enabled = true
      target_port      = local.container_port
      traffic_weight {
        percentage = 100
      }
    }
  }

  dynamic "secret" {
    for_each = local.container_app_secrets

    content {
      name  = secret.key
      value = sensitive(secret.value)
    }
  }

  registry {
    server               = local.registry_server
    username             = local.registry_username
    password_secret_name = "acr-password"
  }

  template {
    container {
      name    = each.value
      image   = "${local.registry_server}/${local.image_name}:${local.image_tag}"
      cpu     = local.container_cpu
      memory  = "${local.container_memory}Gi"
      command = each.value == "worker" ? local.worker_container_command : local.container_command
      dynamic "liveness_probe" {
        for_each = each.value == "main" && local.enable_container_health_probe ? [1] : []

        content {
          interval_seconds = lookup(local.container_health_probe, "interval_seconds")
          transport        = lookup(local.container_health_probe, "transport")
          port             = lookup(local.container_health_probe, "port")
          path             = lookup(local.container_health_probe, "path", null)
        }
      }
      dynamic "env" {
        for_each = local.container_app_environment_variables
        content {
          name        = env.key
          secret_name = sensitive(lookup(env.value, "secretRef", null))
          value       = lookup(env.value, "value", null)
        }
      }
    }
    min_replicas = each.value == "worker" ? local.worker_container_min_replicas : local.container_min_replicas
    max_replicas = each.value == "worker" ? local.worker_container_max_replicas : local.container_max_replicas
  }

  tags = local.tags
}
