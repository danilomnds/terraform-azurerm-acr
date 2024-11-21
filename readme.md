# Module - Azure Container Registry (ACR)
[![COE](https://img.shields.io/badge/Created%20By-CCoE-blue)]()
[![HCL](https://img.shields.io/badge/language-HCL-blueviolet)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/provider-Azure-blue)](https://registry.terraform.io/providers/hashicorp/azurerm/latest)

Module developed to standardize the ACR creation.

## Compatibility Matrix

| Module Version | Terraform Version | AzureRM Version |
|----------------|-------------------| --------------- |
| v1.0.0         | v1.3.6            | 3.37.0          |
| v2.0.0         | v1.9.8            | 4.9.0           |

## Specifying a version

To avoid that your code get updates automatically, is mandatory to set the version using the `source` option. 
By defining the `?ref=***` in the the URL, you can define the version of the module.

Note: The `?ref=***` refers a tag on the git module repo.

## Shared use case

```hcl
module "acrsystemenvid" {
  source = "git::https://github.com/danilomnds/terraform-azurerm-acr?ref=v2.0.0"
  name = "<acr-name>" # acrsystemprd1
  location = "<location>"
  resource_group_name  = "<resource-group-name>"
  sku      = "<Basic/Standard/Premium>"  
  tags = {
    "key1" = "value1"
    "key2" = "value2"    
  }
  # default no replication. Please order the alphabetically by location.
  georeplications = [
    {
      location                = "<brazilsoutheast>"      
    },
    {
      location                = "<eastus>"
      zone_redundancy_enabled = <false>
    }
  ]  
  # default null
  identity = {
    type         = "<UserAssigned/SystemAssigned/SystemAssigned, UserAssigned>"
    identity_ids = ["<full resource id of the managed identity>"]
  }
  # default no network rules
  network_rule_set = {
    default_action = "Deny"
    ip_rule = [
      {
        ip_range = "49.204.225.49/32"
      }
    ]  
  }
  # optional
  scope_map = {
    <scope-map-name> = {
      actions = [
        "repositories/repo/content/read",
        "repositories/repo/content/delete"
      ]
    },
    wso2fqa-scope = {
      actions = [
        "repositories/wso2fqa/redis/content/read",
        "repositories/wso2fqa/redis/content/delete"
      ]
    }
  }
  # the rbac for shared acr grantees only reader on ACR scope. The pull/push permissions are granted on scope_map level
  azure_ad_groups = ["group id 1"]
  acr_shared_rbac = true 
}
output "name" {
  value = module.acrsystemenvid.name
}
output "id" {
  value = module.acrsystemenvid.id
}
```

## Dedicated use case

```hcl
module "acrsystemenvid" {
  source = "git::https://github.com/danilomnds/terraform-azurerm-acr?ref=v2.0.0"
  name = "<acr-name>" acrsystemprd1
  location = "<location>"
  resource_group_name  = "<resource-group-name>"
  sku      = "<Basic/Standard/Premium>"  
  tags = {
    "key1" = "value1"
    "key2" = "value2"    
  }
  # default no replication. Please order the alphabetically by location.
  georeplications = [
    {
      location                = "<brazilsoutheast>"      
    },
    {
      location                = "<eastus>"
      zone_redundancy_enabled = <false>
    }
  ]  
  # default null
  identity = {
    type         = "<UserAssigned/SystemAssigned/SystemAssigned, UserAssigned>"
    identity_ids = ["<full resource id of the managed identity>"]
  }
  # default no network rules
  network_rule_set = {
    default_action = "Deny"
    ip_rule = [
      {
        ip_range = "49.204.225.49/32"
      }
    ]  
  }
  # optional
  scope_map = {
    <scope-map-name> = {
      actions = [
        "repositories/repo/content/read",
        "repositories/repo/content/delete"
      ]
    },
    # A TIM use case
    wso2fqa-scope = {
      actions = [
        "repositories/wso2fqa/redis/content/read",
        "repositories/wso2fqa/redis/content/delete"
      ]
    }
  }
  # the rbac for dedicated acr grantees pull, push and delete at ACR level.
  azure_ad_groups = ["group id 1"]
  acr_dedicated_rbac = true 
}
output "name" {
  value = module.acrsystemenvid.name
}
output "id" {
  value = module.acrsystemenvid.id
}
```


## Input variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | ACR Name | `string` | n/a | `Yes` |
| resource_group_name | resource group where the ACR will be placed | `string` | n/a | `Yes` |
| location | azure region | `string` | n/a | `Yes` |
| sku | acr sku | `string` | n/a | `Yes` |
| admin_enabled | enables admin user | `bool` | `false` | No |
| tags | tags for the acr| `map(string)` | `{}` | No |
| georeplications | locations where the container registry should be geo-replicated | `list(object({}))` | n/a | No |
| network_rule_set | manages network rules for ACR | `object({})` | n/a | No |
| public_network_access_enabled | Whether public network access is allowed for the container registry | `bool` | `false` | No |
| quarantine_policy_enabled | Boolean value that indicates whether quarantine policy is enabled | `bool` | `false` | No |
| retention_policy_in_days | The number of days to retain and untagged manifest after which it gets purged | `number` | `7` | No |
| trust_policy_enabled | indicates whether the policy is enabled | `bool` | `false` | No |
| zone_redundancy_enabled | enables zone redundancy | `bool` | `false` | No |
| export_policy_enabled | enables export policy | `bool` | `true` | No |
| identity | specifies the type of managed identity that should be configured on this ACR | `object({})` | n/a | No |
| encryption | encrypties registry using a customer-managed key | `object({})` | n/a | No |
| anonymous_pull_enabled | allows anonymous unauthenticated pull | `bool` | `false` | No |
| data_endpoint_enabled | enables dedicated data endpoints | `bool` | `false` | No |
| network_rule_bypass_option | allows trusted Azure services to access a network restricted ACR | `string` | `AzureServices` | No |
| scope_map | specifies the scopes and repos that will be created. It also creates a token for each scope map  | `map(object())` | n/a | No |
| azure_ad_groups | list of azure AD groups that will have access to the resources | `list` | `[]` | No |
| acr_shared_rbac | grantees read access on ACR level. Pull and push will be granted on scope_map level | `bool` | `false` | No |
| acr_dedicated_rbac | grantees read, pull, push and delete on ACR level | `bool` | `false` | No |

## Output variables

| Name | Description |
|------|-------------|
| name | acr name |
| id | acr id |

## Documentation

Terraform Azure Container Registry: <br>
[https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry)<br>