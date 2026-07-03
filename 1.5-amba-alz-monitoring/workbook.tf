locals {
  monitoring_workbook_source_id = "/subscriptions/${local.management_subscription_id}"

  monitoring_workbook_serialized_data = jsonencode({
    version = "Notebook/1.0"
    items = [
      {
        type = 1
        content = {
          json = "# AMBA ALZ Monitoring Overview\n이 Workbook은 AMBA ALZ 적용 상태, Alert Rule, Action Group, 최근 Alert를 한 화면에서 확인하기 위한 대시보드입니다."
        }
        name = "title"
      },
      {
        type = 1
        content = {
          json = "## 확인 위치\n- Policy → Assignments / Compliance\n- Monitor → Alerts → Alert rules\n- Monitor → Alerts → Action groups\n- Resource Group → rg-land03-amba-monitoring"
        }
        name = "where-to-check"
      },
      {
        type = 3
        content = {
          version      = "KqlItem/1.0"
          query        = "resources | where type in~ ('microsoft.insights/metricalerts','microsoft.insights/scheduledqueryrules') | project name, type, resourceGroup, location, enabled=tostring(properties.enabled), severity=tostring(properties.severity), window=tostring(properties.windowSize), frequency=tostring(properties.evaluationFrequency), target=coalesce(tostring(properties.scopes[0]), tostring(properties.source.dataSourceId)) | order by resourceGroup asc, name asc"
          size         = 0
          title        = "Alert Rules - Metric Alert / Scheduled Query Rule"
          queryType    = 1
          resourceType = "microsoft.resourcegraph/resources"
          visualization = "table"
        }
        name = "alert-rules"
      },
      {
        type = 3
        content = {
          version      = "KqlItem/1.0"
          query        = "resources | where type =~ 'microsoft.insights/actiongroups' | project name, resourceGroup, location, enabled=tostring(properties.enabled), groupShortName=tostring(properties.groupShortName), emailReceivers=array_length(properties.emailReceivers), smsReceivers=array_length(properties.smsReceivers), webhookReceivers=array_length(properties.webhookReceivers) | order by resourceGroup asc, name asc"
          size         = 0
          title        = "Action Groups - Email / SMS / Webhook"
          queryType    = 1
          resourceType = "microsoft.resourcegraph/resources"
          visualization = "table"
        }
        name = "action-groups"
      },
      {
        type = 3
        content = {
          version      = "KqlItem/1.0"
          query        = "policyresources | where type =~ 'microsoft.authorization/policyassignments' | where tostring(properties.displayName) contains 'AMBA' or tostring(properties.displayName) contains 'Azure Monitor Baseline' or name contains 'amba' | project name, displayName=tostring(properties.displayName), scope=tostring(properties.scope), enforcementMode=tostring(properties.enforcementMode), policyDefinitionId=tostring(properties.policyDefinitionId) | order by displayName asc"
          size         = 0
          title        = "AMBA Policy Assignments"
          queryType    = 1
          resourceType = "microsoft.resourcegraph/resources"
          visualization = "table"
        }
        name = "policy-assignments"
      },
      {
        type = 3
        content = {
          version      = "KqlItem/1.0"
          query        = "alertsmanagementresources | where type =~ 'microsoft.alertsmanagement/alerts' | project alertName=tostring(properties.essentials.alertRule), severity=tostring(properties.essentials.severity), monitorCondition=tostring(properties.essentials.monitorCondition), target=tostring(properties.essentials.targetResource), firedDateTime=todatetime(properties.essentials.startDateTime), resourceGroup | order by firedDateTime desc"
          size         = 0
          title        = "Recent Fired Alerts"
          queryType    = 1
          resourceType = "microsoft.resourcegraph/resources"
          visualization = "table"
        }
        name = "recent-alerts"
      },
      {
        type = 1
        content = {
          json = "## 운영 확인 포인트\n1. Alert Rule이 생성되었는지 확인합니다.\n2. Action Group에 Email/SMS Receiver가 있는지 확인합니다.\n3. Policy Compliance가 Non-compliant이면 Remediation Task를 실행합니다.\n4. VM Guest OS 지표는 Azure Monitor Agent와 Log Analytics 수집이 필요합니다."
        }
        name = "operation-notes"
      }
    ]
    styleSettings = {}
  })
}

resource "azapi_resource" "amba_monitoring_workbook" {
  count = var.enable_monitoring_workbook ? 1 : 0

  type      = "Microsoft.Insights/workbooks@2022-04-01"
  name      = var.monitoring_workbook_name
  parent_id = "/subscriptions/${local.management_subscription_id}/resourceGroups/${var.resource_group_name}"
  location  = var.location
  tags      = local.effective_tags

  body = {
    kind = "shared"
    properties = {
      displayName    = var.monitoring_workbook_display_name
      category       = "workbook"
      serializedData = local.monitoring_workbook_serialized_data
      sourceId       = local.monitoring_workbook_source_id
      version        = "Notebook/1.0"
    }
  }

  depends_on = [module.amba_alz]
}
