# Azure Container Apps Hosting terraform module

[![Terraform CI](https://github.com/DFE-Digital/terraform-azurerm-container-apps-hosting/actions/workflows/continuous-integration-terraform.yml/badge.svg?branch=main)](https://github.com/DFE-Digital/terraform-azurerm-container-apps-hosting/actions/workflows/continuous-integration-terraform.yml?branch=main)
[![Tflint](https://github.com/DFE-Digital/terraform-azurerm-container-apps-hosting/actions/workflows/continuous-integration-tflint.yml/badge.svg?branch=main)](https://github.com/DFE-Digital/terraform-azurerm-container-apps-hosting/actions/workflows/continuous-integration-tflint.yml?branch=main)
[![GitHub release](https://img.shields.io/github/release/DFE-Digital/terraform-azurerm-container-apps-hosting)](https://github.com/DFE-Digital/terraform-azurerm-container-apps-hosting/releases)

This module creates and manages [Azure Container Apps][1], deployed within an [Azure Virtual Network][2].

## Usage

### Terraform

```hcl
module "azure_container_apps_hosting" {
  source = "github.com/DFE-Digital/terraform-azurerm-container-apps-hosting?ref=v0.19.3"

  environment    = "dev"
  project_name   = "myproject"
  azure_location = "uksouth"

  ## Set launch_in_vnet to false to prevent deploying a new Virtual Network
  # launch_in_vnet = false

  ## Specify the name of an existing Virtual Network if you want to use that instead of creating a new one
  # existing_virtual_network = "my-vnet-example-name"

  ## Specify the name of an existing Resource Group to deploy resources into
  # existing_resource_group = "my-existing-resource-group"

  # Set the default IP Range that will be assigned to the Virtual Network used by the Container Apps
  virtual_network_address_space = "172.32.10.0/24"

  # Create an Azure Container Registry and connect it to the Container App Environment
  enable_container_registry = true

  ## Specify the connection details for an existing Container Registry if 'enable_container_registry' is false
  # registry_server   = ""
  # registry_username = ""
  # registry_password = ""

  # Specify the Container Image and Tag that will get pulled from the Container Registry
  image_name = "my-app"
  image_tag  = "latest"

  ## Deploy an Azure SQL Server and create an initial database
  # enable_mssql_database          = true
  # mssql_sku_name                 = "Basic"
  # mssql_max_size_gb              = 2
  # mssql_database_name            = "my-database"
  # mssql_firewall_ipv4_allow_list = [ "8.8.8.8", "1.1.1.1" ]
  # mssql_server_public_access_enabled = true
  # mssql_version = "12.0"
  ## If you want to use a local SQL administrator account you can set a password with
  # mssql_server_admin_password    = "change-me-!!!"
  ## Or, if you want to assign an Azure AD Administrator you must specify
  # mssql_azuread_admin_username = "my-email-address@DOMAIN"
  # mssql_azuread_admin_object_id = "aaaa-bbbb-cccc-dddd"
  ## Restrict SQL authentication to Azure AD
  # mssql_azuread_auth_only = true

  ## Deploy an Azure Database for PostgreSQL flexible server and create an initial database
  # enable_postgresql_database        = true
  # postgresql_server_version         = "11"
  # postgresql_administrator_password = "change-me-!!!"
  # postgresql_administrator_login    = "my-admin-user"
  # postgresql_availability_zone      = "1"
  # postgresql_max_storage_mb         = 32768
  # postgresql_sku_name               = "B_Standard_B1ms"
  # postgresql_collation              = "en_US.utf8"
  # postgresql_charset                = "utf8"
  # postgresql_enabled_extensions     = "citext,pgcrypto"
  # postgresql_network_connectivity_method = "private" # or "public" to enable Public network access
  # postgresql_firewall_ipv4_allow = {
  #   "my-rule-1" = {
  #     start_ip_address = "0.0.0.0",
  #     end_ip_address = "0.0.0.0"
  #   }
  #   # etc
  # }

  ## Deploy an Azure Cache for Redis instance
  # enable_redis_cache                   = true
  # redis_cache_version                  = 6
  # redis_cache_family                   = "C"
  # redis_cache_sku                      = "Basic"
  # redis_cache_capacity                 = 1
  # redis_cache_patch_schedule_day       = "Sunday"
  # redis_cache_patch_schedule_hour      = 23
  # redis_cache_firewall_ipv4_allow_list = [ "8.8.8.8", "1.1.1.1" ]

  ## Deploy an Azure Storage Account and connect it to the Container App
  ## This will expose a 'ConnectionStrings__BlobStorage' environment var to the Container App
  # enable_container_app_blob_storage                = false
  # container_app_blob_storage_public_access_enabled = false
  # container_app_blob_storage_ipv4_allow_list       = [ "8.8.8.8", "1.1.1.1" ]

  ## Increase the hardware resources given to each Container
  # container_cpu    = 1 # core count
  # container_memory = 2 # gigabyte

  # Change the Port number that the Container is listening on
  # container_port = 80

  # Change the number of replicas (commonly called 'instances') for the Container.
  # Setting 'container_max_replicas' to 1 will prevent scaling
  container_min_replicas = 2
  container_max_replicas = 10

  # Maximum number of concurrent HTTP requests before a new replica is created
  container_scale_rule_concurrent_request_count = 100

  ## Enable out-of-hours scale down to reduce resource usage
  # container_scale_rule_scale_down_out_of_hours = false
  # container_scale_rule_out_of_hours_start      = "0 23 * * *" # Must be a valid cron time
  # container_scale_rule_out_of_hours_end        = "0 6 * * *" # Must be a valid cron time

  # Enable a Liveness probe that checks to ensure the Container is responding. If this fails, the Container is restarted
  enable_container_health_probe   = true
  container_health_probe_interval = 60 # seconds
  container_health_probe_protocol = "https" # or "tcp"
  container_health_probe_path     = "/" # relative url to your status page (e.g. /healthcheck, /health, /status)

  # What command should be used to start your Container
  container_command = [ "/bin/bash", "-c", "echo hello && sleep 86400" ]

  ## Set environment variables that are passed to the Container at runtime. (See note below)
  ## It is strongly recommended not to include any sensitive or secret values here
  # container_environment_variables = {
  #   "Environment" = "Development"
  # }

  ## Note: It is recommended to use `container_secret_environment_variables` rather than `container_environment_variables`.
  ##       This ensures that environment variables are set as `secrets` within the container app revision.
  ##       If they are set directly as `env`, they can be exposed when running `az containerapp` commands, especially
  ##       if those commands are ran as part of CI/CD.
  # container_secret_environment_variables = {
  #   "RedirectUri" = "https://www.example.com/signin"
  # }

  ## If your app requires a worker container, you can enable it by setting 'enable_worker_container' to true
  # enable_worker_container       = false
  # worker_container_command      = [ "/bin/bash", "-c", "echo hello && sleep 86400" ]
  # worker_container_min_replicas = 1
  # worker_container_max_replicas = 1

  ## Custom container apps
  # custom_container_apps = {
  #   "my-container-app" = {
  #     # managedEnvironmentId = "/existing-managed-environment-id" # Use this if
  #     #                        you need to launch the container in a different
  #     #                        container app environment
  #     configuration = {
  #       activeRevisionsMode = "single",
  #       secrets = [
  #         {
  #           "name"  = "my-secret",
  #           "value" = "S3creTz"
  #         }
  #       ],
  #       ingress = {
  #         external = false
  #       },
  #       registries = [
  #         {
  #           "server"            = "my-registry.com",
  #           "username"          = "me",
  #           "passwordSecretRef" = "my-secret"
  #         }
  #       ],
  #       dapr = {
  #         enabled = false
  #       }
  #     },
  #     template = {
  #       revisionSuffix = "my-container-app",
  #       containers = [
  #         {
  #           name  = "app",
  #           image = "my-registry.com/my-app:latest",
  #           resources = {
  #             cpu = 0.25,
  #             memory = "0.5Gi"
  #           },
  #           command = [
  #             "say",
  #             "'hello world'",
  #             "-v",
  #             "10"
  #           ]
  #         }
  #       ],
  #       scale = {
  #         minReplicas = 0,
  #         maxReplicas = 1
  #       },
  #       volumes = [
  #         {
  #           "name": "myempty",
  #           "storageType": "EmptyDir"
  #         },
  #         {
  #           "name": "azure-files-volume",
  #           "storageType": "AzureFile",
  #           "storageName": "myazurefiles"
  #         }
  #       ]
  #     }
  #   }
  # }

  # Create a DNS Zone, associate a primary domain and map different DNS Records as you require.
  enable_dns_zone      = true
  dns_zone_domain_name = "example.com"

  ## The SOA record contains important information about a domain and who is responsible for it
  # dns_zone_soa_record  = {
  #   email         = "hello.example.com"
  #   host_name     = "ns1-03.azure-dns.com."
  #   expire_time   = "2419200"
  #   minimum_ttl   = "300"
  #   refresh_time  = "3600"
  #   retry_time    = "300"
  #   serial_number = "1"
  #   ttl           = "3600"
  # }

  ## An A record maps a domain to the physical IP address of the computer hosting that domain
  # dns_a_records = {
  #   "example" = {
  #     ttl = 300,
  #     records = [
  #       "1.2.3.4",
  #       "5.6.7.8",
  #     ]
  #   }
  # }

  ## An ALIAS record is a virtual record type DNSimple created to provide CNAME-like behavior on apex domains
  # dns_alias_records = {
  #   "alias-example" = {
  #     ttl = 300,
  #     target_resource_id = "azure_resource_id",
  #   }
  # }

  ## An AAAA record type is a foundational DNS record when IPv6 addresses are used
  # dns_aaaa_records = {
  #   "aaaa-example" = {
  #     ttl = 300,
  #     records = [
  #       "2001:db8::1:0:0:1",
  #       "2606:2800:220:1:248:1893:25c8:1946",
  #     ]
  #   }
  # }

  # A CAA record is used to specify which certificate authorities (CAs) are allowed to issue certificates for a domain
  # dns_caa_records = {
  #   "caa-example" = {
  #     ttl = 300,
  #     records = [
  #       {
  #         flags = 0,
  #         tag   = "issue",
  #         value = "example.com"
  #       },
  #       {
  #         flags = 0
  #         tag   = "issuewild"
  #         value = ";"
  #       },
  #       {
  #         flags = 0
  #         tag   = "iodef"
  #         value = "mailto:caa@example.com"
  #       }
  #     ]
  #   }
  # }

  ## A CNAME record provides an alias for another domain
  # dns_cname_records = {
  #   "cname-example" = {
  #     ttl    = 300,
  #     record = "example.com",
  #   }
  # }

  ## A MX record directs email to a mail server
  # dns_mx_records = {
  #   "mx-example" = {
  #     ttl = 300,
  #     records = [
  #       {
  #         preference = 10,
  #         exchange   = "mail.example.com"
  #       }
  #     ]
  #   }
  # }

  ## An NS record contains the name of the authoritative name server within the DNS zone
  # dns_ns_records = {
  #   "ns-example" = {
  #     ttl = 300,
  #     records = [
  #       "ns-1.net",
  #       "ns-1.com",
  #       "ns-1.org",
  #       "ns-1.info"
  #     ]
  #   }
  # }

  ## A PTR record is used for reverse DNS lookups, and it matches domain names with IP addresses
  # dns_ptr_records = {
  #   "ptr-example" = {
  #     ttl = 300,
  #     records = [
  #       "example.com",
  #     ]
  #   }
  # }

  ## A SRV record specifies a host and port for specific services such as voice over IP (VoIP), instant messaging etc
  # dns_srv_records = {
  #   "srv-example" = {
  #     ttl = 300,
  #     records = [
  #       {
  #         priority = 1,
  #         weight   = 5,
  #         port     = 8080
  #         target   = target.example.com
  #       }
  #     ]
  #   }
  # }

  ## A TXT record stores text notes on a DNS server
  # dns_txt_records = {
  #   "txt-example" = {
  #     ttl = 300,
  #     records = [
  #       "google-site-authenticator",
  #       "more site information here"
  #     ]
  #   }
  # }

  # Deploy an Azure Front Door CDN. This will be configured as the entrypoint for all traffic accessing your Containers
  enable_cdn_frontdoor           = true
  # cdn_frontdoor_sku            = "Standard_AzureFrontDoor"
  cdn_frontdoor_response_timeout = 300 # seconds

  # Any domains defined here will be associated to the Front Door as acceptable hosts
  cdn_frontdoor_custom_domains = [
    "example.com",
    "www.example.com"
  ]

  # If you want to set up specific domain redirects, you can specify them with 'cdn_frontdoor_host_redirects'
  cdn_frontdoor_host_redirects = [
    {
      "from" = "example.com",
      "to"   = "www.example.com",
    }
  ]

  ## Override the default Origin hostname if you do not want to use the FQDN of the Container App
  # cdn_frontdoor_origin_fqdn_override = "my-backend-host.acme.org"

  ## Override the default origin ports of 80 (HTTP) and 443 (HTTPS) if required
  # cdn_frontdoor_origin_http_port = 8080
  # cdn_frontdoor_origin_https_port = 4443

  # Add additional HTTP Response Headers to include on every response
  cdn_frontdoor_host_add_response_headers = [
    {
      "name"  = "Strict-Transport-Security",
      "value" = "max-age=31536000",
    }
  ]

  # Remove any surplus HTTP Response Headers that you might not want to include
  cdn_frontdoor_remove_response_headers = [
    "Server",
  ]

  # Deploy an Azure Front Door WAF Rate Limiting Policy
  cdn_frontdoor_enable_rate_limiting              = true

  ## Available options are "Prevention" for blocking any matching traffic, or "Detection" just to report on it
  # cdn_frontdoor_waf_mode                        = "Prevention"

  ## Number of minutes to block the requester's IP Address
  cdn_frontdoor_rate_limiting_duration_in_minutes = 5

  ## How many requests can a single IP make in a minute before the WAF policy gets applied
  # cdn_frontdoor_rate_limiting_threshold         = 300

  ## Provide a list of IP Addresses or Ranges that should be exempt from the WAF Policy
  # cdn_frontdoor_rate_limiting_bypass_ip_list    = [ "8.8.8.8/32" ]

  # Prevent traffic from accessing the Container Apps directly
  restrict_container_apps_to_cdn_inbound_only     = true

  ## Should the CDN keep monitoring the backend pool to ensure traffic can be routed?
  enable_cdn_frontdoor_health_probe       = true
  cdn_frontdoor_health_probe_interval     = 300 # seconds
  cdn_frontdoor_health_probe_path         = "/" # relative url to your status page (e.g. /healthcheck, /health, /status)
  cdn_frontdoor_health_probe_request_type = "GET" # HTTP Method (e.g. GET, POST, HEAD etc)

  ## Switch on/off diagnostic settings for the Azure Front Door CDN
  # cdn_frontdoor_enable_waf_logs        = false
  cdn_frontdoor_enable_access_logs       = true # default: false
  cdn_frontdoor_enable_health_probe_logs = true # default: false

  ## Logs are by default exported to a Log Analytics Workspace so enabling these two values are only necessary if you
  ## want to ingest the logs using a 3rd party service (e.g. logit.io)
  # enable_event_hub = true
  # enable_logstash_consumer = true
  ## Specify which Log Analytics tables you want to send to Event Hub
  # eventhub_export_log_analytics_table_names = [
  #   "AppExceptions"
  # ]

  # Monitoring is disabled by default. If enabled, the following metrics will be monitored:
  # Container App: CPU usage, Memory usage, Latency, Revision count, HTTP regional availability
  # Redis (if enabled): Server Load Average
  enable_monitoring                 = true
  monitor_email_receivers           = [ "list@email.com" ]
  monitor_endpoint_healthcheck      = "/"
  ## If you have an existing Logic App Workflow for routing Alerts then you can specify it here instead of creating
  ## a new one
  # existing_logic_app_workflow = {
  #   name                = "my-logic-app"
  #   resource_group_name = "my-other-rg"
  #   trigger_url         = "https://my-callback-url.tld"
  # }
  monitor_enable_slack_webhook      = true
  monitor_slack_webhook_receiver    = "https://hooks.slack.com/services/xxx/xxx/xxx"
  monitor_slack_channel             = "channel-name-or-id"
  alarm_cpu_threshold_percentage    = 80
  alarm_memory_threshold_percentage = 80
  alarm_latency_threshold_ms        = 1000
  alarm_log_ingestion_gb_per_day    = 1

  # Note: that only 1 network watcher can be created within an Azure Subscription
  #     It would probably be advisable to create a Network Watcher outside of this module, as it
  #     may need to be used by other things

  ## Deploy an Azure Network Watcher
  # enable_network_watcher                     = true
  existing_network_watcher_name                = "MyNetworkWatcher"
  existing_network_watcher_resource_group_name = "NetworkWatcherRG"
  # network_watcher_flow_log_retention         = 90 # Days
  # enable_network_watcher_traffic_analytics   = true
  # network_watcher_traffic_analytics_interval = 60

  # Tags are applied to every resource deployed by this module
  # Include them as Key:Value pairs
  tags = {
    "Environment"   = "Dev",
    "My Custom Tag" = "My Value"
  }
}
```

### GitHub Action

You can optinally add a GitHub workflow into your project, using the Reusable GitHub worklow within this repo.

This workflow will build a Docker image, and push it to ACR, then restart the Container app.

You can also conditionally run Cypress tests

```yml
name: Deploy To Environment

on:
  push:
    branches:
      - main
  workflow_dispatch:
    inputs:
      environment:
        type: environment
        description: "Choose an environment to deploy to"
        required: true

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}

jobs:
  deploy-to-environment:
    uses: DFE-Digital/terraform-azurerm-container-apps-hosting/.github/workflows/build-push-and-deploy-to-environment.yml@v0.19.1
    with:
      docker-image-name: "my-app"                 # Required
      docker-build-file-name: "Dockerfile"        # Optional
      docker-build-context: "."                   # Optional
      cypress-tests-enabled: false                # Optional
      cypress-tests-working-directory: "./"       # Optional
      cypress-tests-screenshot-path: "./"         # Optional
      cypress-tests-node-version: "18.x"          # Optional
      environment-name-development: "development" # Optional
      environment-name-staging: "staging"         # Optional
      environment-name-prod: "prod"               # Optional
    secrets:
      azure-acr-client-id: ${{ secrets.AZURE_ACR_CLIENT_ID }}                       # Required
      azure-acr-secret: ${{ secrets.AZURE_ACR_SECRET }}                             # Required
      azure-acr-url: ${{ secrets.AZURE_ACR_URL }}                                   # Required
      azure-aca-credentials: ${{ secrets.AZURE_ACA_CREDENTIALS }}                   # Required
      azure-aca-name: ${{ secrets.AZURE_ACA_NAME }}                                 # Required
      azure-aca-resource-group: ${{ secrets.AZURE_ACA_RESOURCE_GROUP }}             # Required
      cypress-tests-development-run-command: "npm run cy:run -- --env foo='bar'"    # Optional
      cypress-tests-staging-run-command: "npm run cy:run -- --env foo='bar'"        # Optional
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4.5 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | >= 1.6.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.59.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.2.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | 1.8.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.68.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.1 |

## Resources

| Name | Type |
|------|------|
| [azapi_resource.custom_container_apps](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azurerm_application_insights.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) | resource |
| [azurerm_application_insights_standard_web_test.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights_standard_web_test) | resource |
| [azurerm_application_insights_standard_web_test.tls](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights_standard_web_test) | resource |
| [azurerm_cdn_frontdoor_custom_domain.custom_domain](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_custom_domain) | resource |
| [azurerm_cdn_frontdoor_custom_domain_association.custom_domain_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_custom_domain_association) | resource |
| [azurerm_cdn_frontdoor_endpoint.endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_endpoint) | resource |
| [azurerm_cdn_frontdoor_firewall_policy.waf](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_firewall_policy) | resource |
| [azurerm_cdn_frontdoor_origin.origin](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_origin) | resource |
| [azurerm_cdn_frontdoor_origin_group.group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_origin_group) | resource |
| [azurerm_cdn_frontdoor_profile.cdn](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_profile) | resource |
| [azurerm_cdn_frontdoor_route.route](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_route) | resource |
| [azurerm_cdn_frontdoor_rule.add_response_headers](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_rule) | resource |
| [azurerm_cdn_frontdoor_rule.redirect](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_rule) | resource |
| [azurerm_cdn_frontdoor_rule.remove_response_header](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_rule) | resource |
| [azurerm_cdn_frontdoor_rule_set.add_response_headers](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_rule_set) | resource |
| [azurerm_cdn_frontdoor_rule_set.redirects](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_rule_set) | resource |
| [azurerm_cdn_frontdoor_rule_set.remove_response_headers](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_rule_set) | resource |
| [azurerm_cdn_frontdoor_security_policy.waf](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_security_policy) | resource |
| [azurerm_container_app.container_apps](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app) | resource |
| [azurerm_container_app_environment.container_app_env](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_environment) | resource |
| [azurerm_container_registry.acr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry) | resource |
| [azurerm_dns_a_record.dns_a_records](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_a_record) | resource |
| [azurerm_dns_a_record.dns_alias_records](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_a_record) | resource |
| [azurerm_dns_a_record.frontdoor_custom_domain](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_a_record) | resource |
| [azurerm_dns_aaaa_record.dns_aaaa_records](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_aaaa_record) | resource |
| [azurerm_dns_caa_record.dns_caa_records](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_caa_record) | resource |
| [azurerm_dns_cname_record.dns_cname_records](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_cname_record) | resource |
| [azurerm_dns_mx_record.dns_mx_records](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_mx_record) | resource |
| [azurerm_dns_ns_record.dns_ns_records](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_ns_record) | resource |
| [azurerm_dns_ptr_record.dns_ptr_records](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_ptr_record) | resource |
| [azurerm_dns_srv_record.dns_srv_records](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_srv_record) | resource |
| [azurerm_dns_txt_record.dns_txt_records](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_txt_record) | resource |
| [azurerm_dns_txt_record.frontdoor_custom_domain](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_txt_record) | resource |
| [azurerm_dns_zone.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_zone) | resource |
| [azurerm_eventhub.container_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub) | resource |
| [azurerm_eventhub_authorization_rule.listen_only](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_authorization_rule) | resource |
| [azurerm_eventhub_consumer_group.logstash](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_consumer_group) | resource |
| [azurerm_eventhub_namespace.container_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace) | resource |
| [azurerm_log_analytics_data_export_rule.container_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_data_export_rule) | resource |
| [azurerm_log_analytics_query_pack.container_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_query_pack) | resource |
| [azurerm_log_analytics_workspace.container_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_log_analytics_workspace.default_network_watcher_nsg_flow_logs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_logic_app_action_custom.var_affected_resource](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/logic_app_action_custom) | resource |
| [azurerm_logic_app_action_custom.var_alarm_context](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/logic_app_action_custom) | resource |
| [azurerm_logic_app_action_http.slack](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/logic_app_action_http) | resource |
| [azurerm_logic_app_trigger_http_request.webhook](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/logic_app_trigger_http_request) | resource |
| [azurerm_logic_app_workflow.webhook](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/logic_app_workflow) | resource |
| [azurerm_management_lock.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) | resource |
| [azurerm_monitor_action_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_action_group) | resource |
| [azurerm_monitor_diagnostic_setting.cdn](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.container_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.default_network_watcher_nsg_flow_logs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.default_redis_cache](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.webhook](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_metric_alert.count](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.cpu](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.exceptions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.http](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.latency](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.memory](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.redis](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.tls](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_scheduled_query_rules_alert_v2.log-analytics-ingestion](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_scheduled_query_rules_alert_v2) | resource |
| [azurerm_mssql_database.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database) | resource |
| [azurerm_mssql_database_extended_auditing_policy.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database_extended_auditing_policy) | resource |
| [azurerm_mssql_firewall_rule.default_mssql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_firewall_rule) | resource |
| [azurerm_mssql_server.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server) | resource |
| [azurerm_mssql_server_extended_auditing_policy.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server_extended_auditing_policy) | resource |
| [azurerm_network_security_group.container_apps_infra](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.container_apps_infra_allow_frontdoor_inbound_only](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.container_apps_infra_allow_ips_inbound](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_watcher.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_watcher) | resource |
| [azurerm_network_watcher_flow_log.default_network_watcher_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_watcher_flow_log) | resource |
| [azurerm_postgresql_flexible_server.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server) | resource |
| [azurerm_postgresql_flexible_server_configuration.extensions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_configuration) | resource |
| [azurerm_postgresql_flexible_server_database.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_database) | resource |
| [azurerm_postgresql_flexible_server_firewall_rule.firewall_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_firewall_rule) | resource |
| [azurerm_private_dns_a_record.mssql_private_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_a_record) | resource |
| [azurerm_private_dns_a_record.redis_cache_private_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_a_record) | resource |
| [azurerm_private_dns_zone.mssql_private_link](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone.postgresql_private_link](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone.redis_cache_private_link](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.mssql_private_link](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_dns_zone_virtual_network_link.postgresql_private_link](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_dns_zone_virtual_network_link.redis_cache_private_link](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_endpoint.default_mssql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint.default_redis_cache](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_redis_cache.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_cache) | resource |
| [azurerm_redis_firewall_rule.container_app_default_static_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_firewall_rule) | resource |
| [azurerm_redis_firewall_rule.container_app_worker_static_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_firewall_rule) | resource |
| [azurerm_redis_firewall_rule.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/redis_firewall_rule) | resource |
| [azurerm_resource_group.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_route_table.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) | resource |
| [azurerm_storage_account.container_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_account.default_network_watcher_nsg_flow_logs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_account.mssql_security_storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_account_network_rules.container_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_network_rules) | resource |
| [azurerm_storage_account_network_rules.default_network_watcher_nsg_flow_logs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_network_rules) | resource |
| [azurerm_storage_container.container_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_subnet.container_apps_infra_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.container_instances_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.mssql_private_endpoint_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.postgresql_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.redis_cache_private_endpoint_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.redis_cache_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.container_apps_infra](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_route_table_association.container_apps_infra_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) | resource |
| [azurerm_subnet_route_table_association.containerinstances_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) | resource |
| [azurerm_subnet_route_table_association.mssql_private_endpoint_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) | resource |
| [azurerm_subnet_route_table_association.postgresql_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) | resource |
| [azurerm_subnet_route_table_association.redis_cache_private_endpoint_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) | resource |
| [azurerm_subnet_route_table_association.redis_cache_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) | resource |
| [azurerm_virtual_network.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [null_resource.tagging](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [azapi_resource_action.existing_logic_app_workflow_callback_url](https://registry.terraform.io/providers/Azure/azapi/latest/docs/data-sources/resource_action) | data source |
| [azurerm_logic_app_workflow.existing_logic_app_workflow](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/logic_app_workflow) | data source |
| [azurerm_resource_group.existing_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_storage_account_blob_container_sas.container_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account_blob_container_sas) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |
| [azurerm_virtual_network.existing_virtual_network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_cpu_threshold_percentage"></a> [alarm\_cpu\_threshold\_percentage](#input\_alarm\_cpu\_threshold\_percentage) | Specify a number (%) which should be set as a threshold for a CPU usage monitoring alarm | `number` | `80` | no |
| <a name="input_alarm_latency_threshold_ms"></a> [alarm\_latency\_threshold\_ms](#input\_alarm\_latency\_threshold\_ms) | Specify a number in milliseconds which should be set as a threshold for a request latency monitoring alarm | `number` | `1000` | no |
| <a name="input_alarm_log_ingestion_gb_per_day"></a> [alarm\_log\_ingestion\_gb\_per\_day](#input\_alarm\_log\_ingestion\_gb\_per\_day) | Define an alarm threshold for Log Analytics ingestion rate in GB (per day) (Defaults to no limit) | `number` | `0` | no |
| <a name="input_alarm_memory_threshold_percentage"></a> [alarm\_memory\_threshold\_percentage](#input\_alarm\_memory\_threshold\_percentage) | Specify a number (%) which should be set as a threshold for a memory usage monitoring alarm | `number` | `80` | no |
| <a name="input_alarm_tls_expiry_days_remaining"></a> [alarm\_tls\_expiry\_days\_remaining](#input\_alarm\_tls\_expiry\_days\_remaining) | Number of days remaining of TLS validity before an alarm should be raised | `number` | `30` | no |
| <a name="input_azure_location"></a> [azure\_location](#input\_azure\_location) | Azure location in which to launch resources. | `string` | n/a | yes |
| <a name="input_cdn_frontdoor_custom_domains"></a> [cdn\_frontdoor\_custom\_domains](#input\_cdn\_frontdoor\_custom\_domains) | Azure CDN Front Door custom domains | `list(string)` | `[]` | no |
| <a name="input_cdn_frontdoor_custom_domains_create_dns_records"></a> [cdn\_frontdoor\_custom\_domains\_create\_dns\_records](#input\_cdn\_frontdoor\_custom\_domains\_create\_dns\_records) | Should the TXT records and ALIAS/CNAME records be automatically created if the custom domains exist within the DNS Zone? | `bool` | `true` | no |
| <a name="input_cdn_frontdoor_enable_access_logs"></a> [cdn\_frontdoor\_enable\_access\_logs](#input\_cdn\_frontdoor\_enable\_access\_logs) | Toggle the Diagnostic Setting to log Access requests | `bool` | `false` | no |
| <a name="input_cdn_frontdoor_enable_health_probe_logs"></a> [cdn\_frontdoor\_enable\_health\_probe\_logs](#input\_cdn\_frontdoor\_enable\_health\_probe\_logs) | Toggle the Diagnostic Setting to log Health Probe requests | `bool` | `false` | no |
| <a name="input_cdn_frontdoor_enable_rate_limiting"></a> [cdn\_frontdoor\_enable\_rate\_limiting](#input\_cdn\_frontdoor\_enable\_rate\_limiting) | Enable CDN Front Door Rate Limiting. This will create a WAF policy, and CDN security policy. For pricing reasons, there will only be one WAF policy created. | `bool` | `false` | no |
| <a name="input_cdn_frontdoor_enable_waf_logs"></a> [cdn\_frontdoor\_enable\_waf\_logs](#input\_cdn\_frontdoor\_enable\_waf\_logs) | Toggle the Diagnostic Setting to log Web Application Firewall requests | `bool` | `true` | no |
| <a name="input_cdn_frontdoor_forwarding_protocol"></a> [cdn\_frontdoor\_forwarding\_protocol](#input\_cdn\_frontdoor\_forwarding\_protocol) | Azure CDN Front Door forwarding protocol | `string` | `"HttpsOnly"` | no |
| <a name="input_cdn_frontdoor_health_probe_interval"></a> [cdn\_frontdoor\_health\_probe\_interval](#input\_cdn\_frontdoor\_health\_probe\_interval) | Specifies the number of seconds between health probes. | `number` | `120` | no |
| <a name="input_cdn_frontdoor_health_probe_path"></a> [cdn\_frontdoor\_health\_probe\_path](#input\_cdn\_frontdoor\_health\_probe\_path) | Specifies the path relative to the origin that is used to determine the health of the origin. | `string` | `"/"` | no |
| <a name="input_cdn_frontdoor_health_probe_protocol"></a> [cdn\_frontdoor\_health\_probe\_protocol](#input\_cdn\_frontdoor\_health\_probe\_protocol) | Use Http or Https | `string` | `"Https"` | no |
| <a name="input_cdn_frontdoor_health_probe_request_type"></a> [cdn\_frontdoor\_health\_probe\_request\_type](#input\_cdn\_frontdoor\_health\_probe\_request\_type) | Specifies the type of health probe request that is made. | `string` | `"GET"` | no |
| <a name="input_cdn_frontdoor_host_add_response_headers"></a> [cdn\_frontdoor\_host\_add\_response\_headers](#input\_cdn\_frontdoor\_host\_add\_response\_headers) | List of response headers to add at the CDN Front Door `[{ "Name" = "Strict-Transport-Security", "value" = "max-age=31536000" }]` | `list(map(string))` | `[]` | no |
| <a name="input_cdn_frontdoor_host_redirects"></a> [cdn\_frontdoor\_host\_redirects](#input\_cdn\_frontdoor\_host\_redirects) | CDN FrontDoor host redirects `[{ "from" = "example.com", "to" = "www.example.com" }]` | `list(map(string))` | `[]` | no |
| <a name="input_cdn_frontdoor_origin_fqdn_override"></a> [cdn\_frontdoor\_origin\_fqdn\_override](#input\_cdn\_frontdoor\_origin\_fqdn\_override) | Manually specify the hostname that the CDN Front Door should target. Defaults to the Container App FQDN | `string` | `""` | no |
| <a name="input_cdn_frontdoor_origin_host_header_override"></a> [cdn\_frontdoor\_origin\_host\_header\_override](#input\_cdn\_frontdoor\_origin\_host\_header\_override) | Manually specify the host header that the CDN sends to the target. Defaults to the recieved host header. Set to null to set it to the host\_name (`cdn_frontdoor_origin_fqdn_override`) | `string` | `""` | no |
| <a name="input_cdn_frontdoor_origin_http_port"></a> [cdn\_frontdoor\_origin\_http\_port](#input\_cdn\_frontdoor\_origin\_http\_port) | The value of the HTTP port used for the CDN Origin. Must be between 1 and 65535. Defaults to 80 | `number` | `80` | no |
| <a name="input_cdn_frontdoor_origin_https_port"></a> [cdn\_frontdoor\_origin\_https\_port](#input\_cdn\_frontdoor\_origin\_https\_port) | The value of the HTTPS port used for the CDN Origin. Must be between 1 and 65535. Defaults to 443 | `number` | `443` | no |
| <a name="input_cdn_frontdoor_rate_limiting_bypass_ip_list"></a> [cdn\_frontdoor\_rate\_limiting\_bypass\_ip\_list](#input\_cdn\_frontdoor\_rate\_limiting\_bypass\_ip\_list) | List if IP CIDRs to bypass CDN Front Door rate limiting | `list(string)` | `[]` | no |
| <a name="input_cdn_frontdoor_rate_limiting_duration_in_minutes"></a> [cdn\_frontdoor\_rate\_limiting\_duration\_in\_minutes](#input\_cdn\_frontdoor\_rate\_limiting\_duration\_in\_minutes) | CDN Front Door rate limiting duration in minutes | `number` | `1` | no |
| <a name="input_cdn_frontdoor_rate_limiting_threshold"></a> [cdn\_frontdoor\_rate\_limiting\_threshold](#input\_cdn\_frontdoor\_rate\_limiting\_threshold) | Maximum number of concurrent requests before Rate Limiting policy is applied | `number` | `300` | no |
| <a name="input_cdn_frontdoor_remove_response_headers"></a> [cdn\_frontdoor\_remove\_response\_headers](#input\_cdn\_frontdoor\_remove\_response\_headers) | List of response headers to remove at the CDN Front Door | `list(string)` | `[]` | no |
| <a name="input_cdn_frontdoor_response_timeout"></a> [cdn\_frontdoor\_response\_timeout](#input\_cdn\_frontdoor\_response\_timeout) | Azure CDN Front Door response timeout in seconds | `number` | `120` | no |
| <a name="input_cdn_frontdoor_sku"></a> [cdn\_frontdoor\_sku](#input\_cdn\_frontdoor\_sku) | Azure CDN Front Door SKU | `string` | `"Standard_AzureFrontDoor"` | no |
| <a name="input_cdn_frontdoor_waf_mode"></a> [cdn\_frontdoor\_waf\_mode](#input\_cdn\_frontdoor\_waf\_mode) | CDN Front Door waf mode | `string` | `"Prevention"` | no |
| <a name="input_container_app_blob_storage_ipv4_allow_list"></a> [container\_app\_blob\_storage\_ipv4\_allow\_list](#input\_container\_app\_blob\_storage\_ipv4\_allow\_list) | A list of public IPv4 address to grant access to the Blob Storage Account | `list(string)` | `[]` | no |
| <a name="input_container_app_blob_storage_public_access_enabled"></a> [container\_app\_blob\_storage\_public\_access\_enabled](#input\_container\_app\_blob\_storage\_public\_access\_enabled) | Should the Azure Storage Account have Public visibility? | `bool` | `false` | no |
| <a name="input_container_apps_allow_ips_inbound"></a> [container\_apps\_allow\_ips\_inbound](#input\_container\_apps\_allow\_ips\_inbound) | Restricts access to the Container Apps by creating a network security group rule that only allow inbound traffic from the provided list of IPs | `list(string)` | `[]` | no |
| <a name="input_container_command"></a> [container\_command](#input\_container\_command) | Container command | `list(any)` | `[]` | no |
| <a name="input_container_cpu"></a> [container\_cpu](#input\_container\_cpu) | Number of container CPU cores | `number` | `1` | no |
| <a name="input_container_environment_variables"></a> [container\_environment\_variables](#input\_container\_environment\_variables) | Container environment variables | `map(string)` | `{}` | no |
| <a name="input_container_health_probe_interval"></a> [container\_health\_probe\_interval](#input\_container\_health\_probe\_interval) | How often in seconds to poll the Container to determine liveness | `number` | `30` | no |
| <a name="input_container_health_probe_path"></a> [container\_health\_probe\_path](#input\_container\_health\_probe\_path) | Specifies the path that is used to determine the liveness of the Container | `string` | `"/"` | no |
| <a name="input_container_health_probe_protocol"></a> [container\_health\_probe\_protocol](#input\_container\_health\_probe\_protocol) | Use HTTPS or a TCP connection for the Container liveness probe | `string` | `"https"` | no |
| <a name="input_container_max_replicas"></a> [container\_max\_replicas](#input\_container\_max\_replicas) | Container max replicas | `number` | `2` | no |
| <a name="input_container_memory"></a> [container\_memory](#input\_container\_memory) | Container memory in GB | `number` | `2` | no |
| <a name="input_container_min_replicas"></a> [container\_min\_replicas](#input\_container\_min\_replicas) | Container min replicas | `number` | `1` | no |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | Container port | `number` | `80` | no |
| <a name="input_container_secret_environment_variables"></a> [container\_secret\_environment\_variables](#input\_container\_secret\_environment\_variables) | Container environment variables, which are defined as `secrets` within the container app configuration. This is to help reduce the risk of accidentally exposing secrets. | `map(string)` | `{}` | no |
| <a name="input_custom_container_apps"></a> [custom\_container\_apps](#input\_custom\_container\_apps) | Custom container apps, by default deployed within the container app environment | <pre>map(object({<br>    response_export_values = optional(list(string), [])<br>    body = object({<br>      properties = object({<br>        managedEnvironmentId = optional(string, "")<br>        configuration = object({<br>          activeRevisionsMode = optional(string, "single")<br>          secrets             = optional(list(map(string)), [])<br>          ingress             = optional(any, {})<br>          registries          = optional(list(map(any)), [])<br>          dapr                = optional(map(string), {})<br>        })<br>        template = object({<br>          revisionSuffix = string<br>          containers     = list(any)<br>          scale          = map(any)<br>          volumes        = list(map(string))<br>        })<br>      })<br>    })<br>  }))</pre> | `{}` | no |
| <a name="input_dns_a_records"></a> [dns\_a\_records](#input\_dns\_a\_records) | DNS A records to add to the DNS Zone | <pre>map(<br>    object({<br>      ttl : optional(number, 300),<br>      records : list(string)<br>    })<br>  )</pre> | `{}` | no |
| <a name="input_dns_aaaa_records"></a> [dns\_aaaa\_records](#input\_dns\_aaaa\_records) | DNS AAAA records to add to the DNS Zone | <pre>map(<br>    object({<br>      ttl : optional(number, 300),<br>      records : list(string)<br>    })<br>  )</pre> | `{}` | no |
| <a name="input_dns_alias_records"></a> [dns\_alias\_records](#input\_dns\_alias\_records) | DNS ALIAS records to add to the DNS Zone | <pre>map(<br>    object({<br>      ttl : optional(number, 300),<br>      target_resource_id : string<br>    })<br>  )</pre> | `{}` | no |
| <a name="input_dns_caa_records"></a> [dns\_caa\_records](#input\_dns\_caa\_records) | DNS CAA records to add to the DNS Zone | <pre>map(<br>    object({<br>      ttl : optional(number, 300),<br>      records : list(<br>        object({<br>          flags : number,<br>          tag : string,<br>          value : string<br>        })<br>      )<br>    })<br>  )</pre> | `{}` | no |
| <a name="input_dns_cname_records"></a> [dns\_cname\_records](#input\_dns\_cname\_records) | DNS CNAME records to add to the DNS Zone | <pre>map(<br>    object({<br>      ttl : optional(number, 300),<br>      record : string<br>    })<br>  )</pre> | `{}` | no |
| <a name="input_dns_mx_records"></a> [dns\_mx\_records](#input\_dns\_mx\_records) | DNS MX records to add to the DNS Zone | <pre>map(<br>    object({<br>      ttl : optional(number, 300),<br>      records : list(<br>        object({<br>          preference : number,<br>          exchange : string<br>        })<br>      )<br>    })<br>  )</pre> | `{}` | no |
| <a name="input_dns_ns_records"></a> [dns\_ns\_records](#input\_dns\_ns\_records) | DNS NS records to add to the DNS Zone | <pre>map(<br>    object({<br>      ttl : optional(number, 300),<br>      records : list(string)<br>    })<br>  )</pre> | `{}` | no |
| <a name="input_dns_ptr_records"></a> [dns\_ptr\_records](#input\_dns\_ptr\_records) | DNS PTR records to add to the DNS Zone | <pre>map(<br>    object({<br>      ttl : optional(number, 300),<br>      records : list(string)<br>    })<br>  )</pre> | `{}` | no |
| <a name="input_dns_srv_records"></a> [dns\_srv\_records](#input\_dns\_srv\_records) | DNS SRV records to add to the DNS Zone | <pre>map(<br>    object({<br>      ttl : optional(number, 300),<br>      records : list(<br>        object({<br>          priority : number,<br>          weight : number,<br>          port : number,<br>          target : string<br>        })<br>      )<br>    })<br>  )</pre> | `{}` | no |
| <a name="input_dns_txt_records"></a> [dns\_txt\_records](#input\_dns\_txt\_records) | DNS TXT records to add to the DNS Zone | <pre>map(<br>    object({<br>      ttl : optional(number, 300),<br>      records : list(string)<br>    })<br>  )</pre> | `{}` | no |
| <a name="input_dns_zone_domain_name"></a> [dns\_zone\_domain\_name](#input\_dns\_zone\_domain\_name) | DNS zone domain name. If created, records will automatically be created to point to the CDN. | `string` | `""` | no |
| <a name="input_dns_zone_soa_record"></a> [dns\_zone\_soa\_record](#input\_dns\_zone\_soa\_record) | DNS zone SOA record block (https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_zone#soa_record) | `map(string)` | `{}` | no |
| <a name="input_enable_cdn_frontdoor"></a> [enable\_cdn\_frontdoor](#input\_enable\_cdn\_frontdoor) | Enable Azure CDN Front Door. This will use the Container Apps endpoint as the origin. | `bool` | `false` | no |
| <a name="input_enable_cdn_frontdoor_health_probe"></a> [enable\_cdn\_frontdoor\_health\_probe](#input\_enable\_cdn\_frontdoor\_health\_probe) | Enable CDN Front Door health probe | `bool` | `true` | no |
| <a name="input_enable_container_app_blob_storage"></a> [enable\_container\_app\_blob\_storage](#input\_enable\_container\_app\_blob\_storage) | Create an Azure Storage Account and Storage Container to be used for this app | `bool` | `false` | no |
| <a name="input_enable_container_health_probe"></a> [enable\_container\_health\_probe](#input\_enable\_container\_health\_probe) | Enable liveness probes for the Container | `bool` | `true` | no |
| <a name="input_enable_container_registry"></a> [enable\_container\_registry](#input\_enable\_container\_registry) | Set to true to create a container registry | `bool` | n/a | yes |
| <a name="input_enable_dns_zone"></a> [enable\_dns\_zone](#input\_enable\_dns\_zone) | Conditionally create a DNS zone | `bool` | `false` | no |
| <a name="input_enable_event_hub"></a> [enable\_event\_hub](#input\_enable\_event\_hub) | Send Azure Container App logs to an Event Hub sink | `bool` | `false` | no |
| <a name="input_enable_logstash_consumer"></a> [enable\_logstash\_consumer](#input\_enable\_logstash\_consumer) | Create an Event Hub consumer group for Logstash | `bool` | `false` | no |
| <a name="input_enable_monitoring"></a> [enable\_monitoring](#input\_enable\_monitoring) | Create an App Insights instance and notification group for the Container App | `bool` | `false` | no |
| <a name="input_enable_mssql_database"></a> [enable\_mssql\_database](#input\_enable\_mssql\_database) | Set to true to create an Azure SQL server/database, with a private endpoint within the virtual network | `bool` | `false` | no |
| <a name="input_enable_network_watcher"></a> [enable\_network\_watcher](#input\_enable\_network\_watcher) | Enable network watcher. Note: only 1 network watcher per subscription can be created. | `bool` | `false` | no |
| <a name="input_enable_network_watcher_traffic_analytics"></a> [enable\_network\_watcher\_traffic\_analytics](#input\_enable\_network\_watcher\_traffic\_analytics) | Enable network watcher traffic analytics (Requires `enable_network_watcher` to be true) | `bool` | `true` | no |
| <a name="input_enable_postgresql_database"></a> [enable\_postgresql\_database](#input\_enable\_postgresql\_database) | Set to true to create an Azure Postgres server/database, with a private endpoint within the virtual network | `bool` | `false` | no |
| <a name="input_enable_redis_cache"></a> [enable\_redis\_cache](#input\_enable\_redis\_cache) | Set to true to create an Azure Redis Cache, with a private endpoint within the virtual network | `bool` | `false` | no |
| <a name="input_enable_resource_group_lock"></a> [enable\_resource\_group\_lock](#input\_enable\_resource\_group\_lock) | Enabling this will add a Resource Lock to the Resource Group preventing any resources from being deleted. | `bool` | `false` | no |
| <a name="input_enable_worker_container"></a> [enable\_worker\_container](#input\_enable\_worker\_container) | Conditionally launch a worker container. This container uses the same image and environment variables as the default container app, but allows a different container command to be run. The worker container does not expose any ports. | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name. Will be used along with `project_name` as a prefix for all resources. | `string` | n/a | yes |
| <a name="input_environment_accessibility_level"></a> [environment\_accessibility\_level](#input\_environment\_accessibility\_level) | Configure whether your container app allows public ingress or only ingress from within your VNet at the environment level. | `string` | `"external"` | no |
| <a name="input_eventhub_export_log_analytics_table_names"></a> [eventhub\_export\_log\_analytics\_table\_names](#input\_eventhub\_export\_log\_analytics\_table\_names) | List of Log Analytics table names that you want to export to Event Hub. See https://learn.microsoft.com/en-gb/azure/azure-monitor/logs/logs-data-export?tabs=portal#supported-tables for a list of supported tables | `list(string)` | `[]` | no |
| <a name="input_existing_logic_app_workflow"></a> [existing\_logic\_app\_workflow](#input\_existing\_logic\_app\_workflow) | Name, Resource Group and HTTP Trigger URL of an existing Logic App Workflow. Leave empty to create a new Resource | <pre>object({<br>    name : string<br>    resource_group_name : string<br>  })</pre> | <pre>{<br>  "name": "",<br>  "resource_group_name": ""<br>}</pre> | no |
| <a name="input_existing_network_watcher_name"></a> [existing\_network\_watcher\_name](#input\_existing\_network\_watcher\_name) | Use an existing network watcher to add flow logs. | `string` | `""` | no |
| <a name="input_existing_network_watcher_resource_group_name"></a> [existing\_network\_watcher\_resource\_group\_name](#input\_existing\_network\_watcher\_resource\_group\_name) | Existing network watcher resource group. | `string` | `""` | no |
| <a name="input_existing_resource_group"></a> [existing\_resource\_group](#input\_existing\_resource\_group) | Conditionally launch resources into an existing resource group. Specifying this will NOT create a resource group. | `string` | `""` | no |
| <a name="input_existing_virtual_network"></a> [existing\_virtual\_network](#input\_existing\_virtual\_network) | Conditionally use an existing virtual network. The `virtual_network_address_space` must match an existing address space in the VNet. This also requires the resource group name. | `string` | `""` | no |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | Image name | `string` | n/a | yes |
| <a name="input_image_tag"></a> [image\_tag](#input\_image\_tag) | Image tag | `string` | `"latest"` | no |
| <a name="input_launch_in_vnet"></a> [launch\_in\_vnet](#input\_launch\_in\_vnet) | Conditionally launch into a VNet | `bool` | `true` | no |
| <a name="input_monitor_email_receivers"></a> [monitor\_email\_receivers](#input\_monitor\_email\_receivers) | A list of email addresses that should be notified by monitoring alerts | `list(string)` | `[]` | no |
| <a name="input_monitor_enable_slack_webhook"></a> [monitor\_enable\_slack\_webhook](#input\_monitor\_enable\_slack\_webhook) | Enable slack webhooks to send monitoring notifications to a channel. Has no effect if you have defined `existing_logic_app_workflow` | `bool` | `false` | no |
| <a name="input_monitor_endpoint_healthcheck"></a> [monitor\_endpoint\_healthcheck](#input\_monitor\_endpoint\_healthcheck) | Specify a route that should be monitored for a 200 OK status | `string` | `"/"` | no |
| <a name="input_monitor_slack_channel"></a> [monitor\_slack\_channel](#input\_monitor\_slack\_channel) | Slack channel name/id to send messages to. Has no effect if you have defined `existing_logic_app_workflow` | `string` | `""` | no |
| <a name="input_monitor_slack_webhook_receiver"></a> [monitor\_slack\_webhook\_receiver](#input\_monitor\_slack\_webhook\_receiver) | A Slack App webhook URL. Has no effect if you have defined `existing_logic_app_workflow` | `string` | `""` | no |
| <a name="input_monitor_tls_expiry"></a> [monitor\_tls\_expiry](#input\_monitor\_tls\_expiry) | Enable or disable daily TLS expiry check | `bool` | `true` | no |
| <a name="input_mssql_azuread_admin_object_id"></a> [mssql\_azuread\_admin\_object\_id](#input\_mssql\_azuread\_admin\_object\_id) | Object ID of a User within Azure AD that you want to assign as the SQL Server Administrator | `string` | `""` | no |
| <a name="input_mssql_azuread_admin_username"></a> [mssql\_azuread\_admin\_username](#input\_mssql\_azuread\_admin\_username) | Username of a User within Azure AD that you want to assign as the SQL Server Administrator | `string` | `""` | no |
| <a name="input_mssql_azuread_auth_only"></a> [mssql\_azuread\_auth\_only](#input\_mssql\_azuread\_auth\_only) | Set to true to only permit SQL logins from Azure AD users | `bool` | `false` | no |
| <a name="input_mssql_database_name"></a> [mssql\_database\_name](#input\_mssql\_database\_name) | The name of the MSSQL database to create. Must be set if `enable_mssql_database` is true | `string` | `""` | no |
| <a name="input_mssql_firewall_ipv4_allow_list"></a> [mssql\_firewall\_ipv4\_allow\_list](#input\_mssql\_firewall\_ipv4\_allow\_list) | A list of IPv4 Addresses that require remote access to the MSSQL Server | `list(string)` | `[]` | no |
| <a name="input_mssql_max_size_gb"></a> [mssql\_max\_size\_gb](#input\_mssql\_max\_size\_gb) | The max size of the database in gigabytes | `number` | `2` | no |
| <a name="input_mssql_server_admin_password"></a> [mssql\_server\_admin\_password](#input\_mssql\_server\_admin\_password) | The local administrator password for the MSSQL server | `string` | `""` | no |
| <a name="input_mssql_server_public_access_enabled"></a> [mssql\_server\_public\_access\_enabled](#input\_mssql\_server\_public\_access\_enabled) | Enable public internet access to your MSSQL instance. Be sure to specify 'mssql\_firewall\_ipv4\_allow\_list' to restrict inbound connections | `bool` | `false` | no |
| <a name="input_mssql_sku_name"></a> [mssql\_sku\_name](#input\_mssql\_sku\_name) | Specifies the name of the SKU used by the database | `string` | `"Basic"` | no |
| <a name="input_mssql_version"></a> [mssql\_version](#input\_mssql\_version) | Specify the version of Microsoft SQL Server you want to run | `string` | `"12.0"` | no |
| <a name="input_network_watcher_flow_log_retention"></a> [network\_watcher\_flow\_log\_retention](#input\_network\_watcher\_flow\_log\_retention) | Number of days to retain flow logs. Set to 0 to keep all logs. | `number` | `90` | no |
| <a name="input_network_watcher_traffic_analytics_interval"></a> [network\_watcher\_traffic\_analytics\_interval](#input\_network\_watcher\_traffic\_analytics\_interval) | Interval in minutes for Traffic Analytics. | `number` | `60` | no |
| <a name="input_postgresql_administrator_login"></a> [postgresql\_administrator\_login](#input\_postgresql\_administrator\_login) | Specify a login that will be assigned to the administrator when creating the Postgres server | `string` | `""` | no |
| <a name="input_postgresql_administrator_password"></a> [postgresql\_administrator\_password](#input\_postgresql\_administrator\_password) | Specify a password that will be assigned to the administrator when creating the Postgres server | `string` | `""` | no |
| <a name="input_postgresql_availability_zone"></a> [postgresql\_availability\_zone](#input\_postgresql\_availability\_zone) | Specify the availibility zone in which the Postgres server should be located | `string` | `"1"` | no |
| <a name="input_postgresql_charset"></a> [postgresql\_charset](#input\_postgresql\_charset) | Specify the charset to be used for the Postgres database | `string` | `"utf8"` | no |
| <a name="input_postgresql_collation"></a> [postgresql\_collation](#input\_postgresql\_collation) | Specify the collation to be used for the Postgres database | `string` | `"en_US.utf8"` | no |
| <a name="input_postgresql_enabled_extensions"></a> [postgresql\_enabled\_extensions](#input\_postgresql\_enabled\_extensions) | Specify a comma seperated list of Postgres extensions to enable. See https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-extensions#postgres-14-extensions | `string` | `""` | no |
| <a name="input_postgresql_firewall_ipv4_allow"></a> [postgresql\_firewall\_ipv4\_allow](#input\_postgresql\_firewall\_ipv4\_allow) | Map of IP address ranges to add into the postgres firewall. Note: only applicable if postgresql\_network\_connectivity\_method is set to public. | <pre>map(object({<br>    start_ip_address = string<br>    end_ip_address   = string<br>  }))</pre> | `{}` | no |
| <a name="input_postgresql_max_storage_mb"></a> [postgresql\_max\_storage\_mb](#input\_postgresql\_max\_storage\_mb) | Specify the max amount of storage allowed for the Postgres server | `number` | `32768` | no |
| <a name="input_postgresql_network_connectivity_method"></a> [postgresql\_network\_connectivity\_method](#input\_postgresql\_network\_connectivity\_method) | Specify postgresql networking method, public or private. See https://learn.microsoft.com/en-gb/azure/postgresql/flexible-server/concepts-networking | `string` | `"private"` | no |
| <a name="input_postgresql_server_version"></a> [postgresql\_server\_version](#input\_postgresql\_server\_version) | Specify the version of postgres server to run (either 11,12,13 or 14) | `string` | `""` | no |
| <a name="input_postgresql_sku_name"></a> [postgresql\_sku\_name](#input\_postgresql\_sku\_name) | Specify the SKU to be used for the Postgres server | `string` | `"B_Standard_B1ms"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name. Will be used along with `environment` as a prefix for all resources. | `string` | n/a | yes |
| <a name="input_redis_cache_capacity"></a> [redis\_cache\_capacity](#input\_redis\_cache\_capacity) | Redis Cache Capacity | `number` | `0` | no |
| <a name="input_redis_cache_family"></a> [redis\_cache\_family](#input\_redis\_cache\_family) | Redis Cache family | `string` | `"C"` | no |
| <a name="input_redis_cache_firewall_ipv4_allow_list"></a> [redis\_cache\_firewall\_ipv4\_allow\_list](#input\_redis\_cache\_firewall\_ipv4\_allow\_list) | A list of IPv4 address that require remote access to the Redis server | `list(string)` | `[]` | no |
| <a name="input_redis_cache_patch_schedule_day"></a> [redis\_cache\_patch\_schedule\_day](#input\_redis\_cache\_patch\_schedule\_day) | Redis Cache patch schedule day | `string` | `"Sunday"` | no |
| <a name="input_redis_cache_patch_schedule_hour"></a> [redis\_cache\_patch\_schedule\_hour](#input\_redis\_cache\_patch\_schedule\_hour) | Redis Cache patch schedule hour | `number` | `18` | no |
| <a name="input_redis_cache_sku"></a> [redis\_cache\_sku](#input\_redis\_cache\_sku) | Redis Cache SKU | `string` | `"Basic"` | no |
| <a name="input_redis_cache_version"></a> [redis\_cache\_version](#input\_redis\_cache\_version) | Redis Cache version | `number` | `6` | no |
| <a name="input_registry_password"></a> [registry\_password](#input\_registry\_password) | Container registry password (required if `enable_container_registry` is false) | `string` | `""` | no |
| <a name="input_registry_server"></a> [registry\_server](#input\_registry\_server) | Container registry server (required if `enable_container_registry` is false) | `string` | `""` | no |
| <a name="input_registry_username"></a> [registry\_username](#input\_registry\_username) | Container registry username (required if `enable_container_registry` is false) | `string` | `""` | no |
| <a name="input_restrict_container_apps_to_cdn_inbound_only"></a> [restrict\_container\_apps\_to\_cdn\_inbound\_only](#input\_restrict\_container\_apps\_to\_cdn\_inbound\_only) | Restricts access to the Container Apps by creating a network security group rule that only allows 'AzureFrontDoor.Backend' inbound, and attaches it to the subnet of the container app environment. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to all resources | `map(string)` | `{}` | no |
| <a name="input_virtual_network_address_space"></a> [virtual\_network\_address\_space](#input\_virtual\_network\_address\_space) | Virtual Network address space CIDR | `string` | `"172.16.0.0/12"` | no |
| <a name="input_worker_container_command"></a> [worker\_container\_command](#input\_worker\_container\_command) | Container command for the Worker container. `enable_worker_container` must be set to true for this to have any effect. | `list(string)` | `[]` | no |
| <a name="input_worker_container_max_replicas"></a> [worker\_container\_max\_replicas](#input\_worker\_container\_max\_replicas) | Worker ontainer max replicas | `number` | `2` | no |
| <a name="input_worker_container_min_replicas"></a> [worker\_container\_min\_replicas](#input\_worker\_container\_min\_replicas) | Worker container min replicas | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azurerm_dns_zone_name_servers"></a> [azurerm\_dns\_zone\_name\_servers](#output\_azurerm\_dns\_zone\_name\_servers) | Name servers of the DNS Zone |
| <a name="output_azurerm_eventhub_container_app"></a> [azurerm\_eventhub\_container\_app](#output\_azurerm\_eventhub\_container\_app) | Container App Event Hub |
| <a name="output_azurerm_log_analytics_workspace_container_app"></a> [azurerm\_log\_analytics\_workspace\_container\_app](#output\_azurerm\_log\_analytics\_workspace\_container\_app) | Container App Log Analytics Workspace |
| <a name="output_azurerm_resource_group_default"></a> [azurerm\_resource\_group\_default](#output\_azurerm\_resource\_group\_default) | Default Azure Resource Group |
| <a name="output_cdn_frontdoor_dns_records"></a> [cdn\_frontdoor\_dns\_records](#output\_cdn\_frontdoor\_dns\_records) | Azure Front Door DNS Records that must be created manually |
<!-- END_TF_DOCS -->

[1]: https://azure.microsoft.com/en-us/services/container-apps
[2]: https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview
