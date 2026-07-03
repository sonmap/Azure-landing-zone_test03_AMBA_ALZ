output "management_subscription_id" {
  description = "Effective management subscription ID used by this stage."
  value       = local.management_subscription_id
}

output "root_management_group_name" {
  description = "Target Management Group for AMBA ALZ policy assignments."
  value       = var.root_management_group_name
}

output "amba_resource_group_name" {
  description = "AMBA shared resource group name."
  value       = var.resource_group_name
}

output "amba_user_assigned_managed_identity_resource_id" {
  description = "AMBA User Assigned Managed Identity resource ID when created by this stage."
  value       = var.bring_your_own_user_assigned_managed_identity ? var.bring_your_own_user_assigned_managed_identity_resource_id : module.amba_alz[0].user_assigned_managed_identity_resource_id
}

output "monitoring_disable_tag" {
  description = "Tag key and values that exclude resources from AMBA monitoring."
  value = {
    name   = var.amba_disable_tag_name
    values = var.amba_disable_tag_values
  }
}
