resource "azurerm_container_registry" "acr" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = var.admin_enabled
  tags                = local.tags
  dynamic "georeplications" {
    for_each = var.georeplications != null ? var.georeplications : []
    content {
      location                  = georeplications.value.location
      regional_endpoint_enabled = lookup(georeplications.value, "regional_endpoint_enabled", null)
      zone_redundancy_enabled   = lookup(georeplications.value, "zone_redundancy_enabled", null)
      tags                      = merge({ "replication" = format("%s", "georep-${georeplications.value.location}") }, local.tags)
    }
  }
  dynamic "network_rule_set" {
    for_each = var.network_rule_set != null ? [var.network_rule_set] : []
    content {
      default_action = lookup(network_rule_set.value, "default_action", "Allow")
      dynamic "ip_rule" {
        for_each = network_rule_set.value.ip_rule
        content {
          action   = "Allow"
          ip_range = ip_rule.value.ip_range
        }
      }
    }
  }
  public_network_access_enabled = var.public_network_access_enabled
  quarantine_policy_enabled     = var.quarantine_policy_enabled
  retention_policy_in_days      = var.retention_policy_in_days
  trust_policy_enabled          = var.trust_policy_enabled
  zone_redundancy_enabled       = var.zone_redundancy_enabled
  export_policy_enabled         = var.export_policy_enabled
  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    content {
      type         = identity.value.type
      identity_ids = lookup(identity.value, "identity_ids", null)
    }
  }
  dynamic "encryption" {
    for_each = var.encryption != null ? [var.encryption] : []
    content {
      key_vault_key_id   = encryption.value.key_vault_key_id
      identity_client_id = encryption.value.identity_client_id
    }
  }
  anonymous_pull_enabled     = var.anonymous_pull_enabled
  data_endpoint_enabled      = var.data_endpoint_enabled
  network_rule_bypass_option = var.network_rule_bypass_option
  lifecycle {
    ignore_changes = [
      tags["create_date"], georeplications[0].tags["create_date"], georeplications[1].tags["create_date"], georeplications[2].tags["create_date"], georeplications[3].tags["create_date"], georeplications[4].tags["create_date"], georeplications[5].tags["create_date"]
    ]
  }
}

resource "azurerm_container_registry_scope_map" "scope_map" {
  for_each                = var.scope_map != null ? { for k, v in var.scope_map : k => v if v != null } : {}
  name                    = format("%s", each.key)
  resource_group_name     = var.resource_group_name
  container_registry_name = azurerm_container_registry.acr.name
  actions                 = each.value["actions"]
}

resource "azurerm_container_registry_token" "main" {
  for_each                = var.scope_map != null ? { for k, v in var.scope_map : k => v if v != null } : {}
  name                    = replace(format("%s", "${each.key}-token"), "/-scope/", "")
  resource_group_name     = var.resource_group_name
  container_registry_name = azurerm_container_registry.acr.name
  scope_map_id            = element([for k in azurerm_container_registry_scope_map.scope_map : k.id], 0)
  enabled                 = true
}

resource "azurerm_role_assignment" "acr_dedicated_pull_push" {
  depends_on = [azurerm_container_registry.acr]
  for_each = {
    for k, v in toset(var.azure_ad_groups) : k => v
    if var.acr_dedicated_rbac == true && var.acr_shared_rbac != null
  }
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPush"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "acr_dedicated_delete" {
  depends_on = [azurerm_container_registry.acr]
  for_each = {
    for k, v in toset(var.azure_ad_groups) : k => v
    if var.acr_dedicated_rbac == true && var.acr_shared_rbac != null
  }
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrDelete"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "acr_reader" {
  depends_on = [azurerm_container_registry.acr]
  for_each = {
    for k, v in toset(var.azure_ad_groups) : k => v
    if var.acr_dedicated_rbac == true || var.acr_shared_rbac == true
  }
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "Reader"
  principal_id         = each.value
}