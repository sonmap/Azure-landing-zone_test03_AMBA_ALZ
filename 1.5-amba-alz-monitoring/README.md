# 1.5-amba-alz-monitoring

This stage deploys AMBA ALZ monitoring policies for the `azure-landing-zone_test03` lab.

## Purpose

```text
Azure Monitor Baseline Alerts
+ Azure Landing Zones policy pattern
+ Management Group scoped deployment
```

This stage should be placed between:

```text
1-org
1.5-amba-alz-monitoring
2-environments
```

## What it deploys

- AMBA shared resource group
- User Assigned Managed Identity for policy remediation
- AMBA Action Group configuration
- AMBA ALZ policy definitions / policy assignments through Azure Verified Modules
- Disable tag support: `MonitorDisable`

## Required providers

| Provider | Purpose |
|---|---|
| `azurerm` | Creates Azure resources such as resource group, managed identity, action group, role assignments, and policy resources. |
| `azapi` | Reads current Azure tenant/subscription context and supports ARM API access. |
| `alz` | Loads the Azure Landing Zones AMBA library: `platform/amba`. |

## First-time setup

Create a test Management Group and attach only the lab subscription.

```bash
MG_ID="mg-land03-amba-test"
SUB_ID="<SUBSCRIPTION_ID>"

az account management-group create \
  --name "$MG_ID" \
  --display-name "land03 AMBA Test"

az account management-group subscription add \
  --name "$MG_ID" \
  --subscription "$SUB_ID"
```

## Configure

```bash
cp terraform.tfvars.example terraform.tfvars
vi terraform.tfvars
```

Required values:

```hcl
management_subscription_id = "<SUBSCRIPTION_ID>"
root_management_group_name = "mg-land03-amba-test"
action_group_email         = ["owner@example.com"]
```

## Deploy

```bash
terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

## Verify

```bash
az policy assignment list \
  --scope "/providers/Microsoft.Management/managementGroups/mg-land03-amba-test" \
  -o table

az policy state summarize \
  --management-group mg-land03-amba-test \
  -o table

az monitor metrics alert list -o table
az monitor scheduled-query list -o table
```

## Disable AMBA monitoring per resource

Add one of these tags to a target Azure resource:

```text
MonitorDisable = true
MonitorDisable = Dev
MonitorDisable = Sandbox
```

## Notes for azure-landing-zone_test03

The original lab creates VM, AKS, Storage, Key Vault, Azure OpenAI, AI Foundry, and Private Endpoint resources. AMBA ALZ can standardize baseline alerts for supported services.

Guest OS metrics such as filesystem capacity and memory percentage require VM Insights / Azure Monitor Agent / Log Analytics collection.
