variable "enable_monitoring_workbook" {
  type        = bool
  description = "Create an Azure Monitor Workbook dashboard for AMBA ALZ monitoring overview."
  default     = true
}

variable "monitoring_workbook_name" {
  type        = string
  description = "Resource name for the Azure Monitor Workbook. The name should be globally unique in the resource group."
  default     = "a15f0000-0000-4000-8000-000000000001"
}

variable "monitoring_workbook_display_name" {
  type        = string
  description = "Display name shown in Azure Monitor Workbooks."
  default     = "AMBA ALZ Monitoring Overview"
}
