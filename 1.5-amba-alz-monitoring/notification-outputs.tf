output "notification_action_group_id" {
  description = "Notification Action Group resource ID when enable_sms_action_group is true."
  value       = var.enable_sms_action_group ? azurerm_monitor_action_group.amba_sms[0].id : null
}

output "effective_action_group_resource_ids" {
  description = "Action Group resource IDs passed to AMBA policy defaults."
  value       = local.effective_action_group_resource_ids
}
