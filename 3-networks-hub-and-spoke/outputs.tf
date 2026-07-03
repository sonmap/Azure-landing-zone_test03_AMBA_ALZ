output "hub_vnet_id" {
  value = azurerm_virtual_network.hub["hub"].id
}

output "spoke_vnet_ids" {
  value = { for key, vnet in azurerm_virtual_network.spoke : key => vnet.id }
}

output "spoke_subnet_ids" {
  value = { for key, subnet in azurerm_subnet.spoke : key => subnet.id }
}

output "private_dns_zone_ids" {
  value = { for key, zone in azurerm_private_dns_zone.zones : key => zone.id }
}
