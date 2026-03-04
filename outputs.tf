output "cato_appconnector_id" {
  description = "ID of the Cato AppConnector"
  value       = cato_app_connector.this.id
}

output "cato_appconnector_name" {
  description = "Name of the Cato AppConnector"
  value       = cato_app_connector.this.name
}

output "cato_serial_id" {
  description = "Serial ID of the Cato AppConnector"
  value       = try(cato_app_connector.this.serial_number, "N/A")
}

output "firewall_rule_name" {
  description = "Name of the created firewall rule"
  value       = try(google_compute_firewall.allow_ssh_https[0].name, "No Firewall Rule Created")
}

output "boot_disk_name" {
  description = "Boot disk name for the VM"
  value       = google_compute_disk.boot_disk.name
}

output "boot_disk_self_link" {
  description = "Self-link for the boot disk"
  value       = google_compute_disk.boot_disk.self_link
}

output "vm_instance_name" {
  description = "Name of the VM instance"
  value       = google_compute_instance.app_connector.name
}

output "vm_instance_id" {
  value = google_compute_instance.app_connector.id
}

output "vm_mgmt_network_ip" {
  description = "Management network private IP of the VM"
  value       = google_compute_instance.app_connector.network_interface[0].network_ip
}

output "vm_wan_network_ip" {
  description = "WAN network private IP of the VM"
  value       = google_compute_instance.app_connector.network_interface[1].network_ip
}

output "vm_lan_network_ip" {
  description = "LAN network private IP of the VM"
  value       = google_compute_instance.app_connector.network_interface[2].network_ip
}

output "vm_mgmt_public_ip" {
  description = "Management public IP if assigned"
  value       = try(google_compute_instance.app_connector.network_interface[0].access_config[0].nat_ip, "No Public IP")
}

output "vm_wan_public_ip" {
  description = "WAN public IP if assigned"
  value       = try(google_compute_instance.app_connector.network_interface[1].access_config[0].nat_ip, "No Public IP")
}

output "vm_labels" {
  description = "Labels assigned to the VM"
  value       = google_compute_instance.app_connector.labels
}

output "firewall_rule_rfc1918" {
  description = "Firewall rule name for RFC1918 private IP ranges"
  value       = try(google_compute_firewall.allow_rfc1918[0].name, "Firewall Disabled")
}

output "firewall_rule_rfc1918_self_link" {
  description = "Self-link of the RFC1918 firewall rule"
  value       = try(google_compute_firewall.allow_rfc1918[0].self_link, "Firewall Disabled")
}
