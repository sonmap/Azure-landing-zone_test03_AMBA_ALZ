locals {
  sms_receivers_map = {
    for receiver in var.sms_receivers : receiver.name => receiver
    if var.enable_sms_action_group
  }

  sms_email_receivers_map = {
    for email in var.sms_action_group_email_receivers : replace(replace(email, "@", "-at-"), ".", "-") => email
    if var.enable_sms_action_group
  }
}

resource "azurerm_monitor_action_group" "amba_sms" {
  provider = azurerm.management
  count    = var.enable_sms_action_group ? 1 : 0

  name                = var.sms_action_group_name
  resource_group_name = var.resource_group_name
  short_name          = var.sms_action_group_short_name
  enabled             = true
  tags                = local.effective_tags

  dynamic "email_receiver" {
    for_each = local.sms_email_receivers_map
    content {
      name                    = "email-${email_receiver.key}"
      email_address           = email_receiver.value
      use_common_alert_schema = true
    }
  }

  dynamic "sms_receiver" {
    for_each = local.sms_receivers_map
    content {
      name         = sms_receiver.value.name
      country_code = sms_receiver.value.country_code
      phone_number = sms_receiver.value.phone_number
    }
  }

  depends_on = [module.amba_alz]
}
