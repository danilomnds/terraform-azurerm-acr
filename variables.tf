variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "sku" {
  type = string
}

variable "admin_enabled" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "georeplications" {
  description = "A list of Azure locations where the container registry should be geo-replicated"
  type = list(object({
    location                  = string
    regional_endpoint_enabled = optional(bool)
    zone_redundancy_enabled   = optional(bool)
  }))
  default = []
}

variable "network_rule_set" {
  description = "Manage network rules for Azure Container Registries"
  type = object({
    default_action = optional(string)
    ip_rule        = optional(list(object({ ip_range = string })))
  })
  default = null
}

variable "public_network_access_enabled" {
  type    = bool
  default = false
}

variable "quarantine_policy_enabled" {
  type    = bool
  default = false
}

variable "retention_policy_in_days" {
  type    = number
  default = 7
}

variable "trust_policy_enabled" {
  type    = bool
  default = false
}

variable "zone_redundancy_enabled" {
  type    = bool
  default = false
}

variable "export_policy_enabled" {
  type    = bool
  default = true
}

variable "identity" {
  description = "Specifies the type of Managed Service Identity that should be configured on this Container Registry"
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default = null
}

variable "encryption" {
  description = "Encrypt registry using a customer-managed key"
  type = object({
    key_vault_key_id   = string
    identity_client_id = string
  })
  default = null
}

variable "anonymous_pull_enabled" {
  type    = string
  default = false
}

variable "data_endpoint_enabled" {
  type    = string
  default = false
}

variable "network_rule_bypass_option" {
  type    = string
  default = "AzureServices"
}

variable "scope_map" {
  description = "Manages an Azure Container Registry scope map. Scope maps is a preview feature only available in Premium SKU Container registries."
  type = map(object({
    actions = list(string)
  }))
  default = null
}

variable "azure_ad_groups" {
  type    = list(string)
  default = []
}

variable "acr_shared_rbac" {
  type    = bool
  default = false
}

variable "acr_dedicated_rbac" {
  type    = bool
  default = false
}