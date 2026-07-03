output "platform_resource_group_names" {
  value = { for key, rg in azurerm_resource_group.platform : key => rg.name }
}

output "dev_resource_group_names" {
  value = { for key, rg in azurerm_resource_group.dev : key => rg.name }
}

output "department_resource_group_names" {
  value = { for key, rg in azurerm_resource_group.department_dev : key => rg.name }
}
