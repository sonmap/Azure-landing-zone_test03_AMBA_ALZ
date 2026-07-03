output "dev_policy_definition_ids" {
  value = { for key, policy in azurerm_policy_definition.dev : key => policy.id }
}

output "dev_policy_assignment_ids" {
  value = { for key, assignment in azurerm_subscription_policy_assignment.dev : key => assignment.id }
}
