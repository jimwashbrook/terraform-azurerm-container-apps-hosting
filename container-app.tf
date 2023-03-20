resource "azapi_resource" "container_app_env" {
  type      = "Microsoft.App/managedEnvironments@2022-03-01"
  parent_id = local.resource_group.id
  location  = local.resource_group.location
  name      = "${local.resource_prefix}containerapp"

  body = jsonencode({
    properties = {
      appLogsConfiguration = {
        destination = "log-analytics"
        logAnalyticsConfiguration = {
          customerId = azurerm_log_analytics_workspace.container_app.workspace_id
          sharedKey  = azurerm_log_analytics_workspace.container_app.primary_shared_key
        }
      }
      vnetConfiguration = local.launch_in_vnet ? {
        infrastructureSubnetId = azurerm_subnet.container_apps_infra_subnet[0].id
        internal               = false
      } : null
    }
  })

  response_export_values = [
    "properties.staticIp",
  ]

  tags = local.tags
}

resource "azapi_resource" "default" {
  type      = "Microsoft.App/containerApps@2022-03-01"
  parent_id = local.resource_group.id
  location  = local.resource_group.location
  name      = "${local.resource_prefix}-${local.image_name}"
  body = templatefile("${path.module}/template/azapi_resource.tftpl", {
    managedEnvironmentId : azapi_resource.container_app_env.id,

    containerAppEnvironmentVariables : local.container_environment_variables,
    containerAppSecretEnvironmentVariables : local.container_secret_environment_variables,
    containerAppSecretBlobStorageSASToken : local.container_app_blob_storage_sas_secret,

    containerAppResourcesCPU : local.container_cpu,
    containerAppResourcesMemory : local.container_memory,

    containerAppEntrypointCommand : local.container_command,
    containerAppPort : local.container_port,

    containerAppHealthProbes : local.enable_container_health_probe ? concat(
      local.container_health_probe_use_tcp ? [
        {
          type : "Liveness"
          periodSeconds : local.container_health_probe_interval
          tcpSocket : {
            port : local.container_port
          }
        }
      ] : [],
      local.container_health_probe_use_tcp == false && local.container_health_probe_use_https ? [
        {
          type : "Liveness"
          periodSeconds : local.container_health_probe_interval
          httpGet : {
            path : local.container_health_probe_path
            port : local.container_port
          }
        }
      ] : [],
    ) : [],

    containerRegistryURL : local.registry_server,
    containerRegistryUsername : local.registry_username,
    containerRegistryPassword : local.registry_password,
    containerRegistryImageName : local.image_name,
    containerRegistryImageTag : local.image_tag,

    storageAccountEnabled : local.enable_container_app_blob_storage,

    containerAppScaleMinReplicas : local.container_min_replicas,
    containerAppScaleMaxReplicas : local.container_max_replicas,
    containerAppScaleThresholdRequestCount : local.container_scale_rule_concurrent_request_count,
    containerAppScaleEnableQuietHours : local.container_scale_rule_scale_down_out_of_hours,
    containerAppScaleQuietHoursStart : local.container_scale_rule_out_of_hours_start,
    containerAppScaleQuietHoursEnd : local.container_scale_rule_out_of_hours_end

    appInsightsConnectionString : azurerm_application_insights.main.connection_string,
    appInsightsInstrumentationKey : azurerm_application_insights.main.instrumentation_key,
  })

  response_export_values = [
    "properties.outboundIpAddresses",
    "properties.configuration.ingress.fqdn",
  ]

  tags = local.tags
}

resource "azapi_resource" "worker" {
  count = local.enable_worker_container ? 1 : 0

  type      = "Microsoft.App/containerApps@2022-03-01"
  parent_id = local.resource_group.id
  location  = local.resource_group.location
  name      = "${local.resource_prefix}-${local.image_name}-worker"
  body = jsonencode({
    properties : {
      managedEnvironmentId = azapi_resource.container_app_env.id
      configuration = {
        secrets = concat([
          {
            "name" : "acr-password",
            "value" : local.registry_password
          }
          ],
          [
            for env_name, env_value in local.container_secret_environment_variables : {
              name  = lower(replace(env_name, "_", "-"))
              value = env_value
            }
        ])
        registries = [
          {
            "server" : local.registry_server,
            "username" : local.registry_username,
            "passwordSecretRef" : "acr-password"
          }
        ]
      }
      template = {
        containers = [
          {
            name  = "worker"
            image = "${local.registry_server}/${local.image_name}:${local.image_tag}"
            resources = {
              cpu    = local.container_cpu
              memory = "${local.container_memory}Gi"
            }
            command = local.worker_container_command
            env = concat([
              for env_name, env_value in local.container_environment_variables : {
                name  = env_name
                value = env_value
              }
              ],
              [
                for env_name, env_value in local.container_secret_environment_variables : {
                  name      = env_name
                  secretRef = lower(replace(env_name, "_", "-"))
                }
            ])
          }
        ]
        scale = {
          minReplicas = local.worker_container_min_replicas
          maxReplicas = local.worker_container_max_replicas
        }
      }
    }
  })

  response_export_values = [
    "properties.outboundIpAddresses",
  ]

  tags = local.tags
}
