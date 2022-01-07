# Provision a wildcard record for the setup.
# This will be replaced or removed before the platform goes live.
resource "dnsimple_record" "aks_ingress" {
  domain = var.base_domain
  name   = "*.${var.environment_name}.dpl"
  value  = azurerm_public_ip.aks_ingress.ip_address
  type   = "A"
  ttl    = 3600 
}
