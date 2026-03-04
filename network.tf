
# Custom firewall rules on management network
resource "google_compute_firewall" "allow_ssh_https" {
  count   = var.create_firewall_rule ? 1 : 0
  name    = var.mgmt_firewall_rule_name
  network = var.mgmt_compute_network_id

  allow {
    ports    = var.mgmt_allowed_ports
    protocol = "tcp"
  }

  source_ranges = var.management_source_ranges
  target_tags   = var.tags
}

# Firewall rule - allow private IP ranges to access
resource "google_compute_firewall" "allow_rfc1918" {
  count   = var.create_firewall_rule ? 1 : 0
  name    = var.lan_firewall_rule_name
  network = var.lan_compute_network_id
  allow {
    protocol = "all" # Allows all protocols (TCP, UDP, ICMP, etc.)
  }
  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
  priority    = 1000 # Standard priority (lower number = higher priority)
  direction   = "INGRESS"
  description = "Allow all RFC1918 private IP ranges to access the cato-lan-vpc network"
}
