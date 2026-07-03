locals {
  effective_action_group_resource_ids = concat(
    var.bring_your_own_action_group_resource_id,
    var.enable_sms_action_group ? [azurerm_monitor_action_group.amba_sms[0].id] : []
  )
}
