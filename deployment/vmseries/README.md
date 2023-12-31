# NGFW module

## Purpose

Terraform module used to deploy Next Generation Firewalls and related resources.

## Usage

To deploy this infrastructure simply run these commands in the current folder:

```bash
terraform init # only the 1st time
terraform plan -out terraform.tfplan
terraform apply terraform.tfplan
```

To destroy the infrastructure run:

```bash
terraform destroy -auto-approve
```

Keep in mind that due to complexity of this code and the way AzureRM works it might be required to repeat that command several times.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0, < 2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bootstrap"></a> [bootstrap](#module\_bootstrap) | PaloAltoNetworks/vmseries-modules/azurerm//modules/bootstrap | 0.5.0 |
| <a name="module_load_balancer"></a> [load\_balancer](#module\_load\_balancer) | PaloAltoNetworks/vmseries-modules/azurerm//modules/loadbalancer | 0.5.0 |
| <a name="module_vmseries"></a> [vmseries](#module\_vmseries) | PaloAltoNetworks/vmseries-modules/azurerm//modules/vmseries | 0.5.0 |
| <a name="module_vnet"></a> [vnet](#module\_vnet) | github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules//modules/vnet | 5355404 |

## Resources

| Name | Type |
|------|------|
| [azurerm_availability_set.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/availability_set) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [random_password.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_set"></a> [availability\_set](#input\_availability\_set) | A map defining availability sets. Can be used to provide infrastructure high availability when zones cannot be used.<br><br>Key is the AS name, value can contain following properties:<br>- `update_domain_count` - specifies the number of update domains that are used, defaults to 5 (Azure defaults)<br>- `fault_domain_count` - specifies the number of fault domains that are used, defaults to 3 (Azure defaults) | `any` | `{}` | no |
| <a name="input_create_resource_group"></a> [create\_resource\_group](#input\_create\_resource\_group) | When set to `true` it will cause a Resource Group creation. Name of the newly specified RG is controlled by `resource_group_name`.<br>When set to `false` the `resource_group_name` parameter is used to specify a name of an existing Resource Group. | `bool` | `true` | no |
| <a name="input_enable_zones"></a> [enable\_zones](#input\_enable\_zones) | If `true`, enable zone support for resources. | `bool` | `true` | no |
| <a name="input_files"></a> [files](#input\_files) | Map of all files to copy to bucket. The keys are local paths, the values are remote paths. Always use slash `/` as directory separator (unix-like), not the backslash `\`. For example `{"dir/my.txt" = "config/init-cfg.txt"}` | `map(string)` | `{}` | no |
| <a name="input_load_balancers"></a> [load\_balancers](#input\_load\_balancers) | A map containing configuration for all (private and public) Load Balancer that will be created in this deployment.<br><br>Key is the name of the Load Balancer as it will be available in Azure. This name is also used to reference the Load Balancer further in the code.<br>Value is an object containing following properties:<br><br>- `network_security_group_name`: (public LB) a name of a security group created with the `vnet_security` module, an ingress rule will be created in that NSG for each listener. <br>- `network_security_allow_source_ips`: (public LB) a list of IP addresses that will used in the ingress rules.<br>- `frontend_ips`: (both) a map configuring both a listener and a load balancing rule, key is the name that will be used as an application name inside LB config as well as to create a rule in NSG (for public LBs), value is an object with the following properties:<br>  - `create_public_ip`: (public LB) defaults to `false`, when set to `true` a Public IP will be created and associated with a listener<br>  - `public_ip_name`: (public LB) defaults to `null`, when `create_public_ip` is set to `false` this property is used to reference an existing Public IP object in Azure<br>  - `public_ip_resource_group`: (public LB) defaults to `null`, when using an existing Public IP created in a different Resource Group than the currently used use this property is to provide the name of that RG<br>  - `private_ip_address`: (private LB) defaults to `null`, specify a static IP address that will be used by a listener<br>  - `subnet_name`: (private LB) defaults to `null`, when `private_ip_address` is set specifies a subnet to which the LB will be attached, in case of VMSeries this should be a internal/trust subnet<br>  - `zones` - defaults to `null`, specify in which zones you want to create frontend IP address. Pass list with zone coverage, ie: `["1","2","3"]`<br>  - `rules` - a map configuring the actual rules load balancing rules, a key is a rule name, a value is an object with the following properties:<br>    - `protocol`: protocol used by the rule, can be one the following: `TCP`, `UDP` or `All` when creating an HA PORTS rule<br>    - `port`: port used by the rule, for HA PORTS rule set this to `0`<br><br>Example of a public Load Balancer:<pre>"public_https_app" = {<br>  network_security_group_name = "untrust_nsg"<br>  network_security_allow_source_ips = [ "1.2.3.4" ]<br>  frontend_ips = {<br>    "https_app_1" = {<br>      create_public_ip = true<br>      rules = {<br>        "balanceHttps" = {<br>          protocol = "Tcp"<br>          port     = 443<br>        }<br>      }<br>    }<br>  }<br>}</pre>Example of a private Load Balancer with HA PORTS rule:<pre>"ha_ports" = {<br>  frontend_ips = {<br>    "ha-ports" = {<br>      subnet_name        = "trust_snet"<br>      private_ip_address = "10.0.0.1"<br>      rules = {<br>        HA_PORTS = {<br>          port     = 0<br>          protocol = "All"<br>        }<br>      }<br>    }<br>  }<br>}</pre> | `any` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The Azure region to use. | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A prefix that will be added to all created resources.<br>There is no default delimiter applied between the prefix and the resource name. Please include the delimiter in the actual prefix.<br><br>Example:<pre>name_prefix = "test-"</pre>NOTICE. This prefix is not applied to existing resources. If you plan to reuse i.e. a VNET please specify it's full name, even if it is also prefixed with the same value as the one in this property. | `string` | `""` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the Resource Group to . | `string` | n/a | yes |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Default name of the storage account to create.<br>The name you choose must be unique across Azure. The name also must be between 3 and 24 characters in length, and may include only numbers and lowercase letters. | `string` | `"pantfstorage"` | no |
| <a name="input_storage_share_name"></a> [storage\_share\_name](#input\_storage\_share\_name) | Name of storage share to be created that holds `files` for bootstrapping. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to assign to the created resources. | `map(string)` | `{}` | no |
| <a name="input_vmseries"></a> [vmseries](#input\_vmseries) | Map of virtual machines to create to run VM-Series - inbound firewalls. Keys are the individual names, values<br>are objects containing attributes unique to that individual virtual machine:<br><br>- `avzone`: the Azure Availability Zone identifier ("1", "2", "3"). Default is "1" in order to avoid non-HA deployments.<br>- `availability_set_name` : a name of an Availability Set as declared in `availability_set` property. Specify when HA is required but cannot go for zonal deployment.<br>- `bootstrap_options`: Bootstrap options to pass to VM-Series instances, semicolon separated values.<br>- `add_to_appgw_backend` : bool, `false` by default, set this to `true` to add this backend to an Application Gateway.<br><br>- `interfaces`: configuration of all NICs assigned to a VM. A map - key is the type of the interface and will be used to form a name of a NIC resource in Azure. A value is an object with the following properties available:<br>  - `subnet_name`: (string) a name of a subnet as created in using `vnet_security` module<br>  - `create_pip`: (boolean) flag to create Public IP for an interface, defaults to `false`<br>  - `backend_pool_lb_name`: (string) name of a Load Balancer created with the `loadbalancer` module to which a VM should be assigned, defaults to `null`<br>  - `private_ip_address`: (string) a static IP address that should be assigned to an interface, defaults to `null` (in that case DHCP is used)<br><br>Example:<pre>{<br>  "fw00" = {<br>    bootstrap_options = "type=dhcp-client"<br>    avzone = 1<br>    interfaces = {<br>      mgmt = {<br>        subnet_name        = "mgmt"<br>        create_pip         = true<br>        private_ip_address = "10.0.0.1"<br>      }<br>      trust = {<br>        subnet_name          = "trust"<br>        private_ip_address   = "10.0.1.1"<br>        backend_pool_lb_name = "private_lb"<br>      }<br>    }<br>  }<br>}</pre> | `any` | n/a | yes |
| <a name="input_vmseries_password"></a> [vmseries\_password](#input\_vmseries\_password) | Initial administrative password to use for all systems. Set to null for an auto-generated password. | `string` | `null` | no |
| <a name="input_vmseries_sku"></a> [vmseries\_sku](#input\_vmseries\_sku) | VM-Series SKU - list available with `az vm image list -o table --all --publisher paloaltonetworks` | `string` | n/a | yes |
| <a name="input_vmseries_username"></a> [vmseries\_username](#input\_vmseries\_username) | Initial administrative username to use for all systems. | `string` | `"panadmin"` | no |
| <a name="input_vmseries_version"></a> [vmseries\_version](#input\_vmseries\_version) | VM-Series PAN-OS version - list available with `az vm image list -o table --all --publisher paloaltonetworks` | `string` | n/a | yes |
| <a name="input_vmseries_vm_size"></a> [vmseries\_vm\_size](#input\_vmseries\_vm\_size) | Azure VM size (type) to be created. Consult the *VM-Series Deployment Guide* as only a few selected sizes are supported. | `string` | n/a | yes |
| <a name="input_vnet_peerings"></a> [vnet\_peerings](#input\_vnet\_peerings) | A map of peerings between VNETs. Key is a descriptive name of the peering (only for self documentation purposes). Value contains peering configuration (see example and [module documentation](../modules/vnet\_peering/README.md) for all possible options).<br><br>NOTICE. The VNET and Resource Group names are used directly in AzureRM peering resource, therefore they should already include any name prefixes - no prefix will be added here automatically, because the VNET can be either a one created by this code, or an existing one.<br><br>Example:<pre>{<br>  "security-application" = <br>    vnets = {<br>      "one" = {<br>        vnet = "security"<br>        rg   = "sec-rg"<br>      }<br>      "two" = {<br>        vnet = "applications"<br>        rg   = "app-rg"<br>      }<br>    }<br>    both_ways         = true<br>    network_access    = true<br>    forwarded_traffic = true<br>}</pre> | `any` | `{}` | no |
| <a name="input_vnets"></a> [vnets](#input\_vnets) | A map defining VNETs. A key is the VNET name, value is a set of properties like described below.<br><br>For detailed documentation on each property refer to [module documentation](https://github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/blob/v0.5.0/modules/vnet/README.md)<br><br>- `create_virtual_network` : (default: `true`) when set to `true` will create a VNET, `false` will source an existing VNET, in both cases the name of the VNET is specified with `virtual_network_name`<br>- `address_space` : a list of CIDRs for VNET<br>- `resource_group_name` :  (default: current RG) a name of a Resource Group in which the VNET will reside<br><br>- `create_subnets` : (default: `true`) if true, create the Subnets inside the Virtual Network, otherwise use pre-existing subnets<br>- `subnets` : map of Subnets to create<br><br>- `network_security_groups` : map of Network Security Groups to create<br>- `route_tables` : map of Route Tables to create. | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_frontend_ips"></a> [frontend\_ips](#output\_frontend\_ips) | IP Addresses of the load balancers. |
| <a name="output_metrics_instrumentation_keys"></a> [metrics\_instrumentation\_keys](#output\_metrics\_instrumentation\_keys) | The Instrumentation Key of the created instances of Azure Application Insights. An instance is unused by default, but is ready to receive custom PAN-OS metrics from the firewall. To use it, paste this Instrumentation Key into PAN-OS -> Device -> VM-Series -> Azure. |
| <a name="output_password"></a> [password](#output\_password) | Initial administrative password to use for VM-Series. |
| <a name="output_username"></a> [username](#output\_username) | Initial administrative username to use for VM-Series. |
| <a name="output_vmseries_mgmt_ip"></a> [vmseries\_mgmt\_ip](#output\_vmseries\_mgmt\_ip) | IP addresses for the VMSeries management interface. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
