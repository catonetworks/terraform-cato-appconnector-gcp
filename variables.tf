variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "me-west1-a"
}


# Boot Disk Configuration
variable "boot_disk_size" {
  description = "Boot disk size in GB (minimum 10 GB)"
  type        = number
  default     = 20
  validation {
    condition     = var.boot_disk_size >= 10
    error_message = "Boot disk size must be at least 10 GB."
  }
}

variable "boot_disk_image" {
  description = "Boot disk image"
  type        = string
  default     = "projects/catonetworks-public/global/images/app-connector-image"
}


variable "create_firewall_rule" {
  description = "Whether to create the firewall rule for management access"
  type        = bool
  default     = true
}


# Existing VPC Names (REQUIRED)
variable "mgmt_compute_network_id" {
  description = "ID of existing Management Compute Network"
  type        = string
}

variable "wan_compute_network_id" {
  description = "ID of existing WAN Compute Network"
  type        = string
}

variable "lan_compute_network_id" {
  description = "ID of existing LAN Compute Network"
  type        = string
}


# Existing Subnet Names (REQUIRED)
variable "mgmt_subnet_id" {
  description = "ID of existing Management Subnet"
  type        = string
}

variable "wan_subnet_id" {
  description = "ID of existing WAN Subnet"
  type        = string
}

variable "lan_subnet_id" {
  description = "ID of existing LAN Subnet"
  type        = string
}

# Existing IP Names (REQUIRED)
variable "mgmt_static_ip_address" {
  description = "Name of existing Management Static IP"
  type        = string
}

variable "wan_static_ip_address" {
  description = "Name of existing WAN Static IP"
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
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", var.mgmt_network_ip))
    error_message = "Management network IP must be a valid IPv4 address."
  }
}

variable "wan_network_ip" {
  description = "WAN network IP"
  type        = string
}

variable "lan_network_ip" {
  description = "LAN network IP"
  type        = string
}

variable "machine_type" {
  description = "Machine type"
  type        = string
  validation {
    condition     = can(regex("^[a-z][0-9]-[a-z]+(-[0-9]+)?$", var.machine_type))
    error_message = "Machine type must be in the format: family-series-size (e.g., n2-standard-4)."
  }
  default = "n2-standard-4"
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

# Firewall Configuration for Management network
variable "mgmt_firewall_rule_name" {
  description = "Name of the external firewall rule for management network (1-63 chars, lowercase letters, numbers, or hyphens)"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,61}[a-z0-9]$", var.mgmt_firewall_rule_name))
    error_message = "Firewall rule name must be 1-63 characters, start with a letter, and contain only lowercase letters, numbers, or hyphens."
  }
  default = "allow-management-access"
}

variable "lan_firewall_rule_name" {
  description = "Name of the internal firewall rule (1-63 chars, lowercase letters, numbers, or hyphens)"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,61}[a-z0-9]$", var.lan_firewall_rule_name))
    error_message = "Firewall rule name must be 1-63 characters, start with a letter, and contain only lowercase letters, numbers, or hyphens."
  }
  default = "allow-rfc1918-to-cato-lan"
}

variable "mgmt_allowed_ports" {
  description = "List of ports to allow through the firewall on management network"
  type        = list(string)
  default     = null
}

variable "management_source_ranges" {
  description = "Source IP ranges that can access the instance via SSH/HTTPS"
  type        = list(string)
  default     = null
}


variable "labels" {
  description = "Labels to be appended to GCP resources"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to be appended to GCP resources"
  type        = list(string)
  default     = []
}

variable "app_connector_name" {
  type        = string
  description = "Name of the app-connector virtual machine"
  default     = "app-connector"
}

variable "app_connector_description" {
  description = "AppConnector description"
  type        = string
  default     = null
}
variable "app_connector_group" {
  description = "AppConnector group name"
  type        = string
}

variable "app_connector_address" {
  description = "AppConnector address (street)"
  type        = string
  default     = null
}

variable "app_connector_city" {
  description = "AppConnector city name (in the given country)"
  type        = string
}

variable "app_connector_country_code" {
  description = "AppConnector country code"
  type        = string
}

variable "app_connector_state_code" {
  description = "AppConnector state code (required for the USA)"
  type        = string
}

variable "app_connector_timezone" {
  description = "AppConnector timezone"
  type        = string
}

variable "app_connector_primary_pop" {
  description = "Primary POP location (state) for the AppConnector"
  type        = string
  default     = null
}

variable "app_connector_secondary_pop" {
  description = "Secondary POP location (state) for the AppConnector"
  type        = string
  default     = null
}
