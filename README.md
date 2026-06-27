# Cato Networks GCP appConnector Terraform Module

The Cato appConnector module deploys an appConnector instance to connect to the Cato Cloud.

- *Note: This feature is currently in Early Availability (EA) and has been rolled out to a limited set of customer accounts for testing and validation purposes.*

# Pre-reqs
- Install the [Google Cloud Platform CLI](https://cloud.google.com/sdk/docs/install)
`$ /google-cloud-sdk/install.sh`
- Run the following to configure the GCP CLI
`$ gcloud auth application-default login`

# GCP Network and Resource Dependencies

<details>
<summary>Create new GCP VPC and network resources</summary>

The following exmaple shows how to create the required resources as new.

```hcl
# VPC Networks
resource "google_compute_network" "vpc_mgmt" {
  name                    = var.vpc_mgmt_name
  auto_create_subnetworks = false
}

resource "google_compute_network" "vpc_wan" {
  name                    = var.vpc_wan_name
  auto_create_subnetworks = false
}

resource "google_compute_network" "vpc_lan" {
  name                    = var.vpc_lan_name
  auto_create_subnetworks = false
}

# Subnets
resource "google_compute_subnetwork" "subnet_mgmt" {
  name          = var.subnet_mgmt_name
  ip_cidr_range = var.subnet_mgmt_cidr
  network       = google_compute_network.vpc_mgmt.id
  region        = var.region
}

resource "google_compute_subnetwork" "subnet_wan" {
  name          = var.subnet_wan_name
  ip_cidr_range = var.subnet_wan_cidr
  network       = google_compute_network.vpc_wan.id
  region        = var.region
}

resource "google_compute_subnetwork" "subnet_lan" {
  name          = var.subnet_lan_name
  ip_cidr_range = var.subnet_lan_cidr
  network       = google_compute_network.vpc_lan.id
  region        = var.region
}

# Static IPs
resource "google_compute_address" "ip_mgmt" {
  count        = var.public_ip_mgmt ? 1 : 0
  name         = var.ip_mgmt_name
  region       = var.region
  network_tier = var.network_tier
}

resource "google_compute_address" "ip_wan" {
  count        = var.public_ip_wan ? 1 : 0
  name         = var.ip_wan_name
  region       = var.region
  network_tier = var.network_tier
}

resource "google_compute_address" "ip_lan" {
  name         = var.ip_lan_name
  region       = var.region
  address_type = "INTERNAL"
  subnetwork   = google_compute_subnetwork.subnet_lan.id
}
```

</details>

<details>
<summary>Use existing GCP VPC and network resources (data sources)</summary>

The following exmaple shows how to use existing resources in GCP retrieving the necessary values using GCP data sources.

```hcl
# VPC Networks
data "google_compute_network" "vpc_mgmt" {
  name                    = var.vpc_mgmt_name
}

data "google_compute_network" "vpc_wan" {
  name                    = var.vpc_wan_name
}

data "google_compute_network" "vpc_lan" {
  name                    = var.vpc_lan_name
}

# Subnets
data "google_compute_subnetwork" "subnet_mgmt" {
  name          = var.subnet_mgmt_name
  region        = var.region
}

data "google_compute_subnetwork" "subnet_wan" {
  name          = var.subnet_wan_name
  region        = var.region
}

data "google_compute_subnetwork" "subnet_lan" {
  name          = var.subnet_lan_name
  region        = var.region
}

# Static IPs
data "google_compute_address" "ip_mgmt" {
  name         = var.ip_mgmt_name
}

data "google_compute_address" "ip_wan" {
  name         = var.ip_wan_name
}

data "google_compute_address" "ip_lan" {
  name         = var.ip_lan_name
}
```

</details>

## Usage

```hcl
provider "google" {
  project = var.project
  region  = var.region
}

provider "cato" {
  baseurl    = var.baseurl
  token      = var.token
  account_id = var.account_id
}

# GCP/Cato appconnector Module
module "app_connector_gcp" {
  source = "catonetworks/appconnector-gcp/cato"

  zone                     = "me-west1-a"
  create_firewall_rule     = true
  mgmt_compute_network_id  = google_compute_network.vpc_mgmt.id
  wan_compute_network_id   = google_compute_network.vpc_wan.id
  lan_compute_network_id   = google_compute_network.vpc_lan.id
  mgmt_subnet_id           = google_compute_subnetwork.subnet_mgmt.id
  wan_subnet_id            = google_compute_subnetwork.subnet_wan.id
  lan_subnet_id            = google_compute_subnetwork.subnet_lan.id
  mgmt_static_ip_address   = var.public_ip_mgmt ? google_compute_address.ip_mgmt[0].address : null
  wan_static_ip_address    = var.public_ip_wan ? google_compute_address.ip_wan[0].address : null
  network_tier             = var.network_tier
  mgmt_network_ip          = var.mgmt_private_ip
  wan_network_ip           = var.wan_private_ip
  lan_network_ip           = var.lan_private_ip
  machine_type             = "n2-standard-4"
  public_ip_mgmt           = true
  public_ip_wan            = false
  mgmt_firewall_rule_name  = "allow-management-access"
  lan_firewall_rule_name   = "allow-rfc1918-to-cato-lan"
  mgmt_allowed_ports       = ["22", "443"]
  management_source_ranges = ["212.20.115.88/32"]
  labels                   = { environment = "prod" }
  tags                     = ["appconnector"]

  region                      = var.region
  app_connector_name          = "appcon-site1"
  app_connector_description   = "make site1 app accessible"
  app_connector_group         = "site1"
  app_connector_primary_pop   = "New York"
  app_connector_secondary_pop = "Chicago"
}
```

<details>
<summary>Example usage for private IP using NAT for WAN interface</summary>

The below example shows how to use native GCP cloud NAT and Router to support private IP on the virtual socket for WAN interfaces.

## Usage

```hcl
# Provider definition
provider "google" {
  project = var.project
  region  = var.region
}

provider "cato" {
  baseurl    = var.baseurl
  token      = var.token
  account_id = var.account_id
}

# Example variable definition
variable "project" {
  description = "Name of the GCP project"
  type        = string
}

variable "region" {
  description = "Name of the GCP region"
  type        = string
}

variable "cato_token" {
  description = "API Token for the CMA tenant"
  type        = string
  sensitive   = true
}

variable "account_id" {
  description = "Account ID"
  type        = number
}

variable "baseurl" {
  description = "Base URL for the API call"
  type        = string
  default     = "https://api.catonetworks.com/api/v1/graphql2"
  # For US1 CMA, use https://api.us1.catonetworks.com/api/v1/graphql2
}

variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "me-west1-a"
}

# VPC Names
variable "vpc_mgmt_name" {
  description = "Management VPC Name"
  type        = string
}

variable "vpc_wan_name" {
  description = "WAN VPC Name"
  type        = string
}

variable "vpc_lan_name" {
  description = "LAN VPC Name"
  type        = string
}

# Subnet IPv4 CIDRs
variable "subnet_mgmt_cidr" {
  description = "CIDR block for the management subnet"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.subnet_mgmt_cidr))
    error_message = "The value must be a valid CIDR block, e.g., 10.0.0.0/24."
  }
}

variable "subnet_wan_cidr" {
  description = "CIDR block for the WAN subnet"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.subnet_wan_cidr))
    error_message = "The value must be a valid CIDR block, e.g., 10.0.1.0/24."
  }
}

variable "subnet_lan_cidr" {
  description = "CIDR block for the LAN subnet"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.subnet_lan_cidr))
    error_message = "The value must be a valid CIDR block, e.g., 10.0.2.0/24."
  }
}

# Subnet Names (REQUIRED)
variable "subnet_mgmt_name" {
  description = "Name of Management Subnet"
  type        = string
}

variable "subnet_wan_name" {
  description = "Name of WAN Subnet"
  type        = string
}

variable "subnet_lan_name" {
  description = "Name of LAN Subnet"
  type        = string
}

# GCP IP Names (REQUIRED)
variable "ip_mgmt_name" {
  description = "Name of Management Static IP"
  type        = string
}

variable "ip_wan_name" {
  description = "Name of WAN Static IP"
  type        = string
}

variable "ip_lan_name" {
  description = "Name of LAN Static IP"
  type        = string
}

variable "network_tier" {
  description = "Network tier for the public IP"
  type        = string
  default     = "STANDARD"
}

# Network IP Configuration (REQUIRED)
variable "mgmt_network_ip" {
  description = "Management network IP"
  type        = string
}

variable "wan_network_ip" {
  description = "WAN network IP"
  type        = string
}

variable "lan_network_ip" {
  description = "LAN network IP"
  type        = string
}

# Public IP Configuration
variable "public_ip_mgmt" {
  description = "Whether to assign the existing static IP to management interface. If false, no public IP will be assigned."
  type        = bool
  default     = true
}

variable "public_ip_wan" {
  description = "Whether to assign the existing static IP to WAN interface. If false, no public IP will be assigned."
  type        = bool
  default     = true
}

# VPC Networks
resource "google_compute_network" "vpc_mgmt" {
  name                    = var.vpc_mgmt_name
  auto_create_subnetworks = false
}

resource "google_compute_network" "vpc_wan" {
  name                    = var.vpc_wan_name
  auto_create_subnetworks = false
}

resource "google_compute_network" "vpc_lan" {
  name                    = var.vpc_lan_name
  auto_create_subnetworks = false
}

# Subnets
resource "google_compute_subnetwork" "subnet_mgmt" {
  name          = var.subnet_mgmt_name
  ip_cidr_range = var.subnet_mgmt_cidr
  network       = google_compute_network.vpc_mgmt.id
  region        = var.region
}

resource "google_compute_subnetwork" "subnet_wan" {
  name          = var.subnet_wan_name
  ip_cidr_range = var.subnet_wan_cidr
  network       = google_compute_network.vpc_wan.id
  region        = var.region
}

resource "google_compute_subnetwork" "subnet_lan" {
  name          = var.subnet_lan_name
  ip_cidr_range = var.subnet_lan_cidr
  network       = google_compute_network.vpc_lan.id
  region        = var.region
}

# Static IPs
resource "google_compute_address" "ip_mgmt" {
  name         = var.ip_mgmt_name
  region       = var.region
  address_type = "INTERNAL"
  subnetwork   = google_compute_subnetwork.subnet_mgmt.id
  address      = var.mgmt_network_ip
}

resource "google_compute_address" "ip_wan" {
  name         = var.ip_wan_name
  region       = var.region
  address_type = "INTERNAL"
  subnetwork   = google_compute_subnetwork.subnet_wan.id
  address      = var.wan_network_ip
}

resource "google_compute_address" "ip_lan" {
  name         = var.ip_lan_name
  region       = var.region
  address_type = "INTERNAL"
  subnetwork   = google_compute_subnetwork.subnet_lan.id
}

# Cloud Router for the WAN VPC
resource "google_compute_router" "wan_router" {
  name    = "${var.vpc_wan_name}-router"
  region  = var.region
  network = google_compute_network.vpc_wan.self_link
}

# Cloud NAT for private egress on the WAN subnet
resource "google_compute_router_nat" "wan_nat" {
  name                               = "${var.vpc_wan_name}-nat"
  region                             = var.region
  router                             = google_compute_router.wan_router.name
  nat_ip_allocate_option             = "AUTO_ONLY" # Or "MANUAL_ONLY" if you attach reserved externals
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.subnet_wan.self_link
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# GCP/Cato appconnector Module
module "app_connector_gcp" {
  source = "catonetworks/appconnector-gcp/cato"

  zone                     = "me-west1-a"
  create_firewall_rule     = true
  mgmt_compute_network_id  = google_compute_network.vpc_mgmt.id
  wan_compute_network_id   = google_compute_network.vpc_wan.id
  lan_compute_network_id   = google_compute_network.vpc_lan.id
  mgmt_subnet_id           = google_compute_subnetwork.subnet_mgmt.id
  wan_subnet_id            = google_compute_subnetwork.subnet_wan.id
  lan_subnet_id            = google_compute_subnetwork.subnet_lan.id
  mgmt_static_ip_address   = var.public_ip_mgmt ? google_compute_address.ip_mgmt[0].address : null
  wan_static_ip_address    = var.public_ip_wan ? google_compute_address.ip_wan[0].address : null
  network_tier             = var.network_tier
  mgmt_network_ip          = var.mgmt_private_ip
  wan_network_ip           = var.wan_private_ip
  lan_network_ip           = var.lan_private_ip
  machine_type             = "n2-standard-4"
  public_ip_mgmt           = true
  public_ip_wan            = false
  mgmt_firewall_rule_name  = "allow-management-access"
  lan_firewall_rule_name   = "allow-rfc1918-to-cato-lan"
  mgmt_allowed_ports       = ["22", "443"]
  management_source_ranges = ["212.20.115.88/32"]
  labels                   = { environment = "prod" }
  tags                     = ["appconnector"]

  region                      = var.region
  app_connector_name          = "appcon-site1"
  app_connector_description   = "make site1 app accessible"
  app_connector_group         = "site1"
  app_connector_primary_pop   = "New York"
  app_connector_secondary_pop = "Chicago"
}
```

</details>

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_cato"></a> [cato](#requirement\_cato) | >= 0.0.70 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cato"></a> [cato](#provider\_cato) | >= 0.0.70 |
| <a name="provider_google"></a> [google](#provider\_google) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [cato_app_connector.this](https://registry.terraform.io/providers/catonetworks/cato/latest/docs/resources/app_connector) | resource |
| [google_compute_disk.boot_disk](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk) | resource |
| [google_compute_firewall.allow_lan_rfc1918](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_mgmt_ports](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_instance.app_connector](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [null_resource.destroy_delay](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_connector_description"></a> [app\_connector\_description](#input\_app\_connector\_description) | AppConnector description | `string` | `null` | no |
| <a name="input_app_connector_group"></a> [app\_connector\_group](#input\_app\_connector\_group) | AppConnector group name | `string` | n/a | yes |
| <a name="input_app_connector_name"></a> [app\_connector\_name](#input\_app\_connector\_name) | Name of the app-connector virtual machine | `string` | `"app-connector"` | no |
| <a name="input_app_connector_primary_pop"></a> [app\_connector\_primary\_pop](#input\_app\_connector\_primary\_pop) | Primary POP location (state) for the AppConnector | `string` | `null` | no |
| <a name="input_app_connector_secondary_pop"></a> [app\_connector\_secondary\_pop](#input\_app\_connector\_secondary\_pop) | Secondary POP location (state) for the AppConnector | `string` | `null` | no |
| <a name="input_boot_disk_image"></a> [boot\_disk\_image](#input\_boot\_disk\_image) | Boot disk image | `string` | `"projects/catonetworks-public/global/images/app-connector-image"` | no |
| <a name="input_boot_disk_size"></a> [boot\_disk\_size](#input\_boot\_disk\_size) | Boot disk size in GB (minimum 10 GB) | `number` | `20` | no |
| <a name="input_create_firewall_rule"></a> [create\_firewall\_rule](#input\_create\_firewall\_rule) | Whether to create the firewall rule for management access | `bool` | `true` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels to be appended to GCP resources | `map(string)` | `{}` | no |
| <a name="input_lan_compute_network_id"></a> [lan\_compute\_network\_id](#input\_lan\_compute\_network\_id) | ID of existing LAN Compute Network | `string` | n/a | yes |
| <a name="input_lan_firewall_rule_name"></a> [lan\_firewall\_rule\_name](#input\_lan\_firewall\_rule\_name) | Name of the internal firewall rule (1-63 chars, lowercase letters, numbers, or hyphens) | `string` | `"allow-rfc1918-to-cato-lan"` | no |
| <a name="input_lan_network_ip"></a> [lan\_network\_ip](#input\_lan\_network\_ip) | LAN network IP | `string` | n/a | yes |
| <a name="input_lan_subnet_id"></a> [lan\_subnet\_id](#input\_lan\_subnet\_id) | ID of existing LAN Subnet | `string` | n/a | yes |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | Machine type | `string` | `"n2-standard-4"` | no |
| <a name="input_management_source_ranges"></a> [management\_source\_ranges](#input\_management\_source\_ranges) | Source IP ranges that can access the instance via SSH/HTTPS | `list(string)` | `null` | no |
| <a name="input_mgmt_allowed_ports"></a> [mgmt\_allowed\_ports](#input\_mgmt\_allowed\_ports) | List of ports to allow through the firewall on management network | `list(string)` | `null` | no |
| <a name="input_mgmt_compute_network_id"></a> [mgmt\_compute\_network\_id](#input\_mgmt\_compute\_network\_id) | ID of existing Management Compute Network | `string` | n/a | yes |
| <a name="input_mgmt_firewall_rule_name"></a> [mgmt\_firewall\_rule\_name](#input\_mgmt\_firewall\_rule\_name) | Name of the external firewall rule for management network (1-63 chars, lowercase letters, numbers, or hyphens) | `string` | `"allow-management-access"` | no |
| <a name="input_mgmt_network_ip"></a> [mgmt\_network\_ip](#input\_mgmt\_network\_ip) | Management network IP | `string` | n/a | yes |
| <a name="input_mgmt_static_ip_address"></a> [mgmt\_static\_ip\_address](#input\_mgmt\_static\_ip\_address) | Name of existing Management Static IP | `string` | n/a | yes |
| <a name="input_mgmt_subnet_id"></a> [mgmt\_subnet\_id](#input\_mgmt\_subnet\_id) | ID of existing Management Subnet | `string` | n/a | yes |
| <a name="input_network_tier"></a> [network\_tier](#input\_network\_tier) | Network tier for the public IP | `string` | `"STANDARD"` | no |
| <a name="input_public_ip_mgmt"></a> [public\_ip\_mgmt](#input\_public\_ip\_mgmt) | Whether to assign the existing static IP to management interface. If false, no public IP will be assigned. | `bool` | `true` | no |
| <a name="input_public_ip_wan"></a> [public\_ip\_wan](#input\_public\_ip\_wan) | Whether to assign the existing static IP to WAN interface. If false, no public IP will be assigned. | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | GCP Region | `string` | n/a | yes |
| <a name="input_site_location"></a> [site\_location](#input\_site\_location) | Site location information. If all fields are null, location will be automatically determined from the GCP region. | <pre>object({<br/>    city_name    = optional(string)<br/>    country_code = optional(string)<br/>    state_code   = optional(string)<br/>    timezone     = optional(string)<br/>  })</pre> | <pre>{<br/>  "city_name": null,<br/>  "country_code": null,<br/>  "state_code": null,<br/>  "timezone": null<br/>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be appended to GCP resources | `list(string)` | `[]` | no |
| <a name="input_wan_compute_network_id"></a> [wan\_compute\_network\_id](#input\_wan\_compute\_network\_id) | ID of existing WAN Compute Network | `string` | n/a | yes |
| <a name="input_wan_network_ip"></a> [wan\_network\_ip](#input\_wan\_network\_ip) | WAN network IP | `string` | n/a | yes |
| <a name="input_wan_static_ip_address"></a> [wan\_static\_ip\_address](#input\_wan\_static\_ip\_address) | Name of existing WAN Static IP | `string` | n/a | yes |
| <a name="input_wan_subnet_id"></a> [wan\_subnet\_id](#input\_wan\_subnet\_id) | ID of existing WAN Subnet | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | GCP Zone | `string` | `"me-west1-a"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_boot_disk_name"></a> [boot\_disk\_name](#output\_boot\_disk\_name) | Boot disk name for the VM |
| <a name="output_boot_disk_self_link"></a> [boot\_disk\_self\_link](#output\_boot\_disk\_self\_link) | Self-link for the boot disk |
| <a name="output_cato_appconnector_id"></a> [cato\_appconnector\_id](#output\_cato\_appconnector\_id) | ID of the Cato AppConnector |
| <a name="output_cato_appconnector_name"></a> [cato\_appconnector\_name](#output\_cato\_appconnector\_name) | Name of the Cato AppConnector |
| <a name="output_cato_serial_id"></a> [cato\_serial\_id](#output\_cato\_serial\_id) | Serial ID of the Cato AppConnector |
| <a name="output_firewall_rule_name"></a> [firewall\_rule\_name](#output\_firewall\_rule\_name) | Name of the created firewall rule |
| <a name="output_firewall_rule_rfc1918"></a> [firewall\_rule\_rfc1918](#output\_firewall\_rule\_rfc1918) | Firewall rule name for RFC1918 private IP ranges |
| <a name="output_firewall_rule_rfc1918_self_link"></a> [firewall\_rule\_rfc1918\_self\_link](#output\_firewall\_rule\_rfc1918\_self\_link) | Self-link of the RFC1918 firewall rule |
| <a name="output_site_location"></a> [site\_location](#output\_site\_location) | The resolved site location from GCP region mapping |
| <a name="output_vm_instance_id"></a> [vm\_instance\_id](#output\_vm\_instance\_id) | ID of the VM instance |
| <a name="output_vm_instance_name"></a> [vm\_instance\_name](#output\_vm\_instance\_name) | Name of the VM instance |
| <a name="output_vm_labels"></a> [vm\_labels](#output\_vm\_labels) | Labels assigned to the VM |
| <a name="output_vm_lan_network_ip"></a> [vm\_lan\_network\_ip](#output\_vm\_lan\_network\_ip) | LAN network private IP of the VM |
| <a name="output_vm_mgmt_network_ip"></a> [vm\_mgmt\_network\_ip](#output\_vm\_mgmt\_network\_ip) | Management network private IP of the VM |
| <a name="output_vm_mgmt_public_ip"></a> [vm\_mgmt\_public\_ip](#output\_vm\_mgmt\_public\_ip) | Management public IP if assigned |
| <a name="output_vm_wan_network_ip"></a> [vm\_wan\_network\_ip](#output\_vm\_wan\_network\_ip) | WAN network private IP of the VM |
| <a name="output_vm_wan_public_ip"></a> [vm\_wan\_public\_ip](#output\_vm\_wan\_public\_ip) | WAN public IP if assigned |
<!-- END_TF_DOCS -->
