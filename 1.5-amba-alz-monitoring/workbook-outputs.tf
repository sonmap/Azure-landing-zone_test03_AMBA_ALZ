output "monitoring_workbook_id" {
  description = "Azure Monitor Workbook resource ID."
  value       = var.enable_monitoring_workbook ? azapi_resource.amba_monitoring_workbook[0].id : null
}

output "monitoring_workbook_display_name" {
  description = "Azure Monitor Workbook display name."
  value       = var.enable_monitoring_workbook ? var.monitoring_workbook_display_name : null
}
