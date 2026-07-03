# AMBA ALZ Monitoring Dashboard

This stage creates an optional Azure Monitor Workbook dashboard.

## Purpose

The workbook helps operators view AMBA ALZ monitoring status from one screen:

- Alert Rules
- Action Groups
- AMBA Policy Assignments
- Recent Fired Alerts
- Operation notes

## Terraform resources

```text
azapi_resource.amba_monitoring_workbook
```

The workbook is deployed to the AMBA shared resource group:

```text
rg-land03-amba-monitoring
```

## Enable or disable

The workbook is enabled by default.

```hcl
enable_monitoring_workbook = true
monitoring_workbook_display_name = "AMBA ALZ Monitoring Overview"
```

To disable:

```hcl
enable_monitoring_workbook = false
```

## Open in Azure Portal

```text
Azure Portal
→ Monitor
→ Workbooks
→ AMBA ALZ Monitoring Overview
```

Or:

```text
Azure Portal
→ Resource groups
→ rg-land03-amba-monitoring
→ AMBA ALZ Monitoring Overview
```

## Verify with CLI

```bash
terraform -chdir=1.5-amba-alz-monitoring output monitoring_workbook_id

az resource list \
  -g rg-land03-amba-monitoring \
  --resource-type Microsoft.Insights/workbooks \
  -o table
```

## Workbook sections

### Alert Rules

Shows Azure Monitor metric alerts and scheduled query rules.

### Action Groups

Shows Email, SMS, and Webhook receiver counts.

### AMBA Policy Assignments

Shows AMBA-related policy assignments.

### Recent Fired Alerts

Shows recent alert instances from Azure Alerts Management data.

## Notes

- Alert Rules appear after AMBA policies are assigned and remediation has created them.
- Guest OS metrics require Azure Monitor Agent and Log Analytics data collection.
- Some queries may show no data until resources and alerts exist.
