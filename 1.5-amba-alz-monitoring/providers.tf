data "azapi_client_config" "current" {}

provider "azapi" {}

provider "alz" {
  library_references = [{
    path = "platform/amba"
    ref  = var.amba_library_ref
  }]
}

provider "azurerm" {
  alias           = "management"
  subscription_id = var.management_subscription_id != "" ? var.management_subscription_id : data.azapi_client_config.current.subscription_id
  features {}
}
