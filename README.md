# Azure Landing Zone Test03 + AMBA ALZ

This repository adds an **AMBA ALZ monitoring stage** for the `azure-landing-zone_test03` lab design.

AMBA ALZ means:

```text
Azure Monitor Baseline Alerts + Azure Landing Zones
```

It deploys Azure Monitor baseline alert policies at Management Group scale by using Azure Policy / Initiative / DeployIfNotExists patterns.

## Recommended integration point

Add this stage between `1-org` and `2-environments` in the original landing-zone flow:

```text
0-bootstrap
1-org
1.5-amba-alz-monitoring   <-- new AMBA ALZ stage
2-environments
3-networks-hub-and-spoke
4-projects
5-app-infra
```

Why here?

- `1-org` already handles subscription guardrails and basic policy assignments.
- AMBA ALZ is also policy-driven, but it is Management Group / ALZ library based.
- Deploying AMBA before workload resources allows policies to create or remediate alerts as resources are added later.

## Directory layout

```text
.
├── README.md
└── 1.5-amba-alz-monitoring/
    ├── main.tf
    ├── outputs.tf
    ├── providers.tf
    ├── variables.tf
    ├── versions.tf
    └── terraform.tfvars.example
```

## Prerequisites

The deployment identity needs permissions to manage:

- Management Group policy assignments
- Policy definitions and initiatives
- Role assignments
- Resource Group / Managed Identity / Action Group resources in the management subscription

For lab testing, create a dedicated Management Group and attach only the test subscription.

```bash
MG_ID="mg-land03-amba-test"
SUB_ID="<subscription-id>"

az account management-group create \
  --name "$MG_ID" \
  --display-name "land03 AMBA Test"

az account management-group subscription add \
  --name "$MG_ID" \
  --subscription "$SUB_ID"
```

## Configure

```bash
cd 1.5-amba-alz-monitoring
cp terraform.tfvars.example terraform.tfvars
vi terraform.tfvars
```

Example:

```hcl
location                   = "koreacentral"
management_subscription_id = "<subscription-id>"
root_management_group_name = "mg-land03-amba-test"

resource_group_name                 = "rg-land03-amba-monitoring"
user_assigned_managed_identity_name = "id-land03-amba-monitoring"

action_group_email = [
  "owner@example.com"
]

amba_disable_tag_name   = "MonitorDisable"
amba_disable_tag_values = ["true", "Test", "Dev", "Sandbox"]
```

## Deploy

```bash
az login
az account set --subscription "<subscription-id>"

terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

## Verify

Policy assignments:

```bash
az policy assignment list \
  --scope "/providers/Microsoft.Management/managementGroups/mg-land03-amba-test" \
  -o table
```

Policy compliance:

```bash
az policy state summarize \
  --management-group mg-land03-amba-test \
  -o table
```

Alert rules:

```bash
az monitor metrics alert list \
  --query "[].{name:name, rg:resourceGroup, enabled:enabled, severity:severity}" \
  -o table
```

Scheduled query alert rules:

```bash
az monitor scheduled-query list \
  --query "[].{name:name, rg:resourceGroup, enabled:enabled}" \
  -o table
```

## Important notes

- Do not apply this directly to a production Management Group first.
- Test with a dedicated Management Group and one lab subscription.
- AMBA policies can create many alert rules depending on the resources under the scope.
- Use the tag below to disable monitoring for specific resources:

```text
MonitorDisable = true
MonitorDisable = Dev
MonitorDisable = Sandbox
```

## Relationship with `azure-landing-zone_test03`

The original landing zone creates resources such as:

- Private VM
- Private AKS
- Storage Account
- Key Vault
- Azure OpenAI / Cognitive Account
- Private Endpoint
- Hub and Spoke VNets

AMBA ALZ mainly helps standardize monitoring for supported resources such as VM, AKS, Storage, Key Vault, and network components.

For guest OS memory and filesystem disk usage, make sure VM Insights / Azure Monitor Agent / Log Analytics collection is enabled in the workload stages.
