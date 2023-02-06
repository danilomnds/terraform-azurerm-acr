variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "sku" {
  type = string
}

variable "admin_enabled" {
  type    = bool
  default = false
}

variable "public_network_access_enabled" {
  type    = bool
  default = false
}

variable "quarantine_policy_enabled" {
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

variable "georeplications" {
  description = "A list of Azure locations where the container registry should be geo-replicated"
  type = list(object({
    location                = string
    zone_redundancy_enabled = optional(bool)
  }))
  default = []
}

variable "network_rule_set" { # change this to match actual objects
  description = "Manage network rules for Azure Container Registries"
  type = object({
    default_action  = optional(string)
    ip_rule         = optional(list(object({ ip_range = string })))
    virtual_network = optional(list(object({ subnet_id = string })))
  })
  default = null
}

variable "retention_policy" {
  description = "Set a retention policy for untagged manifests"
  type = object({
    days    = optional(number)
    enabled = optional(bool)
  })
  default = null
}

variable "trust_policy" {
  type    = bool
  default = false
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
variable "tags" {
  type    = map(string)
  default = {}
}

variable "scope_map" {
  description = "Manages an Azure Container Registry scope map. Scope maps is a preview feature only available in Premium SKU Container registries."
  type = map(object({
    actions = list(string)
  }))
  default = null
}