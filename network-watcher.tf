resource "azurerm_network_watcher" "default" {
  count = local.enable_network_watcher ? 1 : 0

  name                = "${local.resource_prefix}default"
  location            = local.resource_group.location
  resource_group_name = local.resource_group.name

  tags = local.tags
}

resource "azurerm_storage_account" "default_network_watcher_nsg_flow_logs" {
  count = local.network_watcher_name != "" ? 1 : 0

  name                          = "${replace(local.resource_prefix, "-", "")}nwnsgd"
  resource_group_name           = local.resource_group.name
  location                      = local.resource_group.location
  account_tier                  = "Standard"
  account_kind                  = "StorageV2"
  account_replication_type      = "LRS"
  min_tls_version               = "TLS1_2"
  enable_https_traffic_only     = true
  public_network_access_enabled = false

  tags = local.tags
}

resource "azurerm_log_analytics_workspace" "default_network_watcher_nsg_flow_logs" {
  count = local.network_watcher_name != "" && local.enable_network_watcher_traffic_analytics ? 1 : 0

  name                = "${local.resource_prefix}nwnsgdefault"
  location            = local.resource_group.location
  resource_group_name = local.resource_group.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = local.tags
}

resource "azurerm_monitor_diagnostic_setting" "default_network_watcher_nsg_flow_logs" {
  count = local.network_watcher_name != "" && local.enable_network_watcher_traffic_analytics ? 1 : 0

  name               = "${local.resource_prefix}-nwnsgd-diag"
  target_resource_id = azurerm_storage_account.default_network_watcher_nsg_flow_logs[0].id

  log_analytics_workspace_id     = azurerm_log_analytics_workspace.default_network_watcher_nsg_flow_logs[0].id
  log_analytics_destination_type = "Dedicated"

  metric {
    category = "Capacity"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  metric {
    category = "Transaction"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }
}

resource "azurerm_network_watcher_flow_log" "default_network_watcher_nsg" {
  for_each = local.network_watcher_name != "" ? local.network_security_group_ids : {}

  network_watcher_name = local.network_watcher_name
  resource_group_name  = local.network_watcher_resource_group_name
  name                 = "${local.resource_prefix}nsg${element(split("/", each.value), length(split("/", each.value)) - 1)}"

  network_security_group_id = each.value
  storage_account_id        = azurerm_storage_account.default_network_watcher_nsg_flow_logs[0].id
  enabled                   = true

  retention_policy {
    enabled = local.network_watcher_flow_log_retention == 0 ? false : true
    days    = local.network_watcher_flow_log_retention
  }

  dynamic "traffic_analytics" {
    for_each = local.network_watcher_name != "" && local.enable_network_watcher_traffic_analytics ? [0] : []
    content {
      enabled               = true
      workspace_id          = azurerm_log_analytics_workspace.default_network_watcher_nsg_flow_logs[0].workspace_id
      workspace_region      = azurerm_log_analytics_workspace.default_network_watcher_nsg_flow_logs[0].location
      workspace_resource_id = azurerm_log_analytics_workspace.default_network_watcher_nsg_flow_logs[0].id
      interval_in_minutes   = local.network_watcher_traffic_analytics_interval
    }
  }

  tags = local.tags
}

resource "azurerm_storage_account_network_rules" "default_network_watcher_nsg_flow_logs" {
  count = local.network_watcher_name != "" ? 1 : 0

  storage_account_id = azurerm_storage_account.default_network_watcher_nsg_flow_logs[0].id
  default_action     = "Deny"
  bypass             = ["AzureServices", "Logging", "Metrics"]

  dynamic "private_link_access" {
    for_each = azurerm_network_watcher_flow_log.default_network_watcher_nsg

    content {
      endpoint_resource_id = private_link_access.value.id
    }
  }
}
