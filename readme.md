# Module - Azure Container Registry (ACR)
[![COE](https://img.shields.io/badge/Created%20By-CCoE-blue)]()
[![HCL](https://img.shields.io/badge/language-HCL-blueviolet)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/provider-Azure-blue)](https://registry.terraform.io/providers/hashicorp/azurerm/latest)

Module developed to standardize the ACR creation.

## Compatibility Matrix

| Module Version | Terraform Version | AzureRM Version |
|----------------|-------------------| --------------- |
| v1.0.0       | v1.3.6 | 3.37.0        |

## Specifying a version

To avoid that your code get updates automatically, is mandatory to set the version using the `source` option. 
By defining the `?ref=***` in the the URL, you can define the version of the module.

Note: The `?ref=***` refers a tag on the git module repo.

## Use case

```hcl
module "<acr-name>" {
  source = "git::https://github.com/danilomnds/terraform-azurerm-acr?ref=v1.0.0"
  acr_name = "<acr-name>"
  location = "<location>"
  rg_name  = "<resource-group-name>"
  sku      = "<Basic/Standard/Premium>"  
  tags = {
    "key1" = "value1"
    "key2" = "value2"    
  }
  # default no replication. Please order the alphabetically by location.
  georeplications = [
    {
      location                = "<brazilsoutheast>"
      zone_redundancy_enabled = <false>
    },
    {
      location                = "<eastus>"
      zone_redundancy_enabled = <false>
    }
  ]
  # default 7/enable = false
  retention_policy = {
    days    = <15>
    enabled = <true>
  }
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
      },
    ]
    virtual_network = [
      {
        subnet_id = "full resource id of the subnet 1"
      },
      {
        subnet_id = "full resource id of the subnet 2"
      }
    ]
  }
  # optional
  scope_map = {
    <scope-map-name1> = {
      actions = [
        "repositories/repo1/image/content/read",
        "repositories/repo1/image/content/delete"
      ]
    },    
    <scope-map-name2> = {
      actions = [
        "repositories/repo2/image/content/read",
        "repositories/repo2/image/content/delete"
      ]
    }
  }
}
```

## Input variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| acr_name | ACR Name | `string` | n/a | `Yes` |
| location | azure region | `string` | n/a | `Yes` |
| rg_name | resource group where the ACR will be placed | `string` | n/a | `Yes` |
| sku | acr sku | `string` | n/a | `Yes` |
| admin_enabled | enables admin user | `bool` | `false` | No |
| public_network_access_enabled | enables public access | `bool` | `false` | No |
| zone_redundancy_enabled | enables zone redundancy | `bool` | `false` | No |
| export_policy_enabled | enables export policy | `bool` | `true` | No |
| anonymous_pull_enabled | allows anonymous unauthenticated pull | `bool` | `false` | No |
| data_endpoint_enabled | enables dedicated data endpoints | `bool` | `false` | No |
| network_rule_bypass_option | allows trusted Azure services to access a network restricted ACR | `string` | `AzureServices` | No |
| georeplications | locations where the container registry should be geo-replicated | `list(object)` | n/a | No |
| network_rule_set | manages network rules for ACR | `object()` | n/a | No |
| retention_policy | sets a retention policy for untagged manifests | `object()` | n/a | No |
| trust_policy | indicates whether the policy is enabled | `bool` | `false` | No |
| identity | specifies the type of managed identity that should be configured on this ACR | `object()` | n/a | No |
| encryption | encrypties registry using a customer-managed key | `object()` | n/a | No |
| tags | tags for the acr| `map(string)` | `{}` | No |
| scope_map | specifies the scopes and repos that will be created. It also creates a token for each scope map  | `map(object())` | n/a | No |


## Output variables

| Name | Description |
|------|-------------|
| acr_name | acr name |
| acr_id | acr id |

## Documentation

Terraform Azure Container Registry: <br>
[https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry)<br>