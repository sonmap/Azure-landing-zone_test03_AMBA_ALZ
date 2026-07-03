locals {
  app_config_provider_all = {
    for row in csvdecode(file("${path.module}/csv/app_config.csv")) :
    row.key => row
    if lower(row.create) == "true"
  }

  app_config_provider = local.app_config_provider_all["default"]
}

provider "azurerm" {
  features {}
  subscription_id = local.app_config_provider.dev_subscription_id
}
