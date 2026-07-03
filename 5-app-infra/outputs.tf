output "vm_ids" {
  value = { for key, vm in azurerm_linux_virtual_machine.vm : key => vm.id }
}

output "aks_ids" {
  value = { for key, aks in azurerm_kubernetes_cluster.aks : key => aks.id }
}

output "storage_account_ids" {
  value = { for key, st in azurerm_storage_account.ai : key => st.id }
}

output "key_vault_ids" {
  value = { for key, kv in azurerm_key_vault.ai : key => kv.id }
}
