locals {
  network_config_provider_all = {
    for row in csvdecode(file("${path.module}/csv/network_config.csv")) :
    row.key => row
    if lower(row.create) == "true"
  }

  network_config_provider = local.network_config_provider_all["default"]
}

provider "azurerm" {
  alias = "platform"
  features {}
  subscription_id = local.network_config_provider.platform_subscription_id
}

provider "azurerm" {
  alias = "dev"
  features {}
  subscription_id = local.network_config_provider.dev_subscription_id
}
