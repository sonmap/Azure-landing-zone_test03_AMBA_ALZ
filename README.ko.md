# Azure Landing Zone Test03 + AMBA ALZ 통합 구성

이 저장소는 기존 `azure-landing-zone_test03` Landing Zone 실습 구조에 **AMBA ALZ 모니터링 stage**를 추가한 통합 Terraform 예제입니다.

## 전체 적용 순서

```text
0-bootstrap
1-org
1.5-amba-alz-monitoring
2-environments
3-networks-hub-and-spoke
4-projects
5-app-infra
```

## 각 stage 역할

| Stage | Directory | 역할 |
|---|---|---|
| 0 | `0-bootstrap` | Terraform state 저장용 Resource Group, Storage Account, Container 생성 |
| 1 | `1-org` | 구독 예산, 기본 Azure Policy Definition/Assignment 생성 |
| 1.5 | `1.5-amba-alz-monitoring` | Management Group 범위 AMBA ALZ 모니터링 정책 배포 |
| 2 | `2-environments` | Hub, Dev, 부서별 Resource Group 생성 |
| 3 | `3-networks-hub-and-spoke` | Hub/Spoke VNet, Subnet, Route Table, Private DNS, Peering 생성 |
| 4 | `4-projects` | 프로젝트 카탈로그 정보를 Terraform state로 기록 |
| 5 | `5-app-infra` | VM, AKS, Storage, Key Vault, Azure OpenAI, Private Endpoint 생성 |

## AMBA ALZ를 1.5 단계로 넣은 이유

`1-org`는 기본 구독 정책과 예산을 담당합니다. AMBA ALZ는 별도의 Management Group 기반 모니터링 정책/Initiative를 배포하므로 기존 `1-org`에 섞지 않고 `1.5-amba-alz-monitoring`으로 분리했습니다.

이렇게 하면 다음 흐름이 됩니다.

```text
1-org                 = 기본 Guardrail
1.5-amba-alz-monitoring = 표준 모니터링 정책
2~5 stage             = 실제 Azure 리소스 생성
```

## 테스트 Management Group 생성

운영 Management Group에 바로 적용하지 말고 테스트용 Management Group을 먼저 만드십시오.

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

## 실행 전 수정할 값

각 CSV와 tfvars 예제에서 아래 값을 실제 환경에 맞게 수정해야 합니다.

```text
<SUBSCRIPTION_ID>
<DEV_SUBSCRIPTION_ID>
<ADMIN_PUBLIC_IP>/32
owner@example.com
REPLACE_WITH_SECURE_PASSWORD
```

특히 확인할 파일은 다음입니다.

```text
0-bootstrap/csv/bootstrap_config.csv
1-org/csv/org_config.csv
1.5-amba-alz-monitoring/terraform.tfvars.example
2-environments/csv/env_config.csv
3-networks-hub-and-spoke/csv/network_config.csv
5-app-infra/csv/app_config.csv
```

## 검증

```bash
for d in \
  0-bootstrap \
  1-org \
  1.5-amba-alz-monitoring \
  2-environments \
  3-networks-hub-and-spoke \
  4-projects \
  5-app-infra; do
  echo "### $d"
  terraform -chdir="$d" init -backend=false -input=false
  terraform -chdir="$d" validate
done
```

## 배포

각 stage를 순서대로 실행합니다.

```bash
terraform -chdir=0-bootstrap init
terraform -chdir=0-bootstrap apply

terraform -chdir=1-org init
terraform -chdir=1-org apply

terraform -chdir=1.5-amba-alz-monitoring init
terraform -chdir=1.5-amba-alz-monitoring apply

terraform -chdir=2-environments init
terraform -chdir=2-environments apply

terraform -chdir=3-networks-hub-and-spoke init
terraform -chdir=3-networks-hub-and-spoke apply

terraform -chdir=4-projects init
terraform -chdir=4-projects apply

terraform -chdir=5-app-infra init
terraform -chdir=5-app-infra apply
```

## AMBA 확인

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

## 주의사항

- AMBA ALZ는 Management Group 하위 Subscription 전체에 영향을 줄 수 있습니다.
- 처음에는 테스트 Management Group과 테스트 Subscription 1개로만 검증하십시오.
- VM Guest OS 메모리/파일시스템 디스크 사용률은 Azure Monitor Agent, VM Insights, Log Analytics 구성이 필요합니다.
- 리소스별 AMBA 제외가 필요하면 `MonitorDisable=true` 태그를 사용하십시오.
