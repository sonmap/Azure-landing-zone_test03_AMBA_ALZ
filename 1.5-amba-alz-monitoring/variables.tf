variable "location" {
  type        = string
  description = "Azure region for AMBA shared monitoring resources."
  default     = "koreacentral"
}

variable "management_subscription_id" {
  type        = string
  description = "Subscription ID used to host AMBA shared resources such as resource group, managed identity, and action group. Leave empty to use the current Azure CLI subscription."
  default     = ""
}

variable "root_management_group_name" {
  type        = string
  description = "Target Management Group ID/name where AMBA ALZ policies will be assigned. Use a test Management Group first."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group for AMBA shared monitoring resources."
  default     = "rg-land03-amba-monitoring"
}

variable "user_assigned_managed_identity_name" {
  type        = string
  description = "User Assigned Managed Identity name used by AMBA DeployIfNotExists policy remediation."
  default     = "id-land03-amba-monitoring"
}

variable "bring_your_own_user_assigned_managed_identity" {
  type        = bool
  description = "Set true when an existing User Assigned Managed Identity is provided."
  default     = false
}

variable "bring_your_own_user_assigned_managed_identity_resource_id" {
  type        = string
  description = "Existing User Assigned Managed Identity resource ID. Used only when bring_your_own_user_assigned_managed_identity is true."
  default     = ""
}

variable "bring_your_own_action_group_resource_id" {
  type        = list(string)
  description = "Existing Action Group resource IDs to use instead of AMBA-created action group resources."
  default     = []
}

variable "bring_your_own_alert_processing_rule_resource_id" {
  type        = string
  description = "Existing Alert Processing Rule resource ID."
  default     = ""
}

variable "action_group_email" {
  type        = list(string)
  description = "Email receivers for AMBA Action Group."
  default     = []
}

variable "action_group_arm_role_id" {
  type        = list(string)
  description = "ARM role receiver IDs for AMBA Action Group."
  default     = []
}

variable "webhook_service_uri" {
  type        = list(string)
  description = "Webhook receiver service URIs for AMBA Action Group."
  default     = []
}

variable "event_hub_resource_id" {
  type        = list(string)
  description = "Event Hub receiver resource IDs."
  default     = []
}

variable "function_resource_id" {
  type        = string
  description = "Azure Function receiver resource ID."
  default     = ""
}

variable "function_trigger_uri" {
  type        = string
  description = "Azure Function trigger URI."
  default     = ""
}

variable "logic_app_resource_id" {
  type        = string
  description = "Logic App receiver resource ID."
  default     = ""
}

variable "logic_app_callback_url" {
  type        = string
  description = "Logic App callback URL."
  default     = ""
}

variable "amba_disable_tag_name" {
  type        = string
  description = "Tag name used to disable AMBA monitoring per resource."
  default     = "MonitorDisable"
}

variable "amba_disable_tag_values" {
  type        = list(string)
  description = "Tag values that disable AMBA monitoring per resource."
  default     = ["true", "Test", "Dev", "Sandbox"]
}

variable "amba_library_ref" {
  type        = string
  description = "AMBA ALZ library reference version consumed by Azure/alz provider."
  default     = "2026.06.2"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags for AMBA shared resources."
  default = {
    Environment = "lab"
    Owner       = "son"
    Workload    = "amba-alz-monitoring"
  }
}
