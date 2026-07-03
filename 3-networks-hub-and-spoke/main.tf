locals {
  network_config_all = {
    for row in csvdecode(file("${path.module}/csv/network_config.csv")) :
    row.key => row
    if lower(row.create) == "true"
  }

  network_config = local.network_config_all["default"]

  tags = {
    Environment = local.network_config.environment
    Purpose     = local.network_config.purpose
    Owner       = local.network_config.owner
    CostCenter  = local.network_config.cost_center
    ExpiryDate  = local.network_config.expiry_date
  }

  resource_groups_all = {
    for row in csvdecode(file("${path.module}/csv/resource_groups.csv")) :
    row.key => row
    if lower(row.create) == "true"
  }

  networks_all = {
    for row in csvdecode(file("${path.module}/csv/networks.csv")) :
    row.key => row
    if lower(row.create) == "true"
  }

  subnets_all = {
    for row in csvdecode(file("${path.module}/csv/subnets.csv")) :
    row.key => row
    if lower(row.create) == "true"
  }

  routes_all = {
    for row in csvdecode(file("${path.module}/csv/routes.csv")) :
    row.key => row
    if lower(row.create) == "true"
  }

  private_dns_zones_all = {
    for row in csvdecode(file("${path.module}/csv/private_dns_zones.csv")) :
    row.key => row
    if lower(row.create) == "true"
  }

  hub_rg_name = local.resource_groups_all["hub"].name
  dev_rg_name = local.resource_groups_all["dev"].name

  platform_networks = {
    for key, row in local.networks_all : key => row
    if row.subscription_key == "platform"
  }

  dev_networks = {
    for key, row in local.networks_all : key => row
    if row.subscription_key == "dev"
  }

  platform_subnets = {
    for key, row in local.subnets_all : key => row
    if row.subscription_key == "platform"
  }

  dev_subnets = {
    for key, row in local.subnets_all : key => row
    if row.subscription_key == "dev"
  }

  dev_routes = {
    for key, row in local.routes_all : key => row
    if row.subscription_key == "dev"
  }
}

data "azurerm_resource_group" "hub" {
  provider = azurerm.platform
  name     = local.hub_rg_name
}

data "azurerm_resource_group" "dev" {
  provider = azurerm.dev
  name     = local.dev_rg_name
}

resource "azurerm_virtual_network" "hub" {
  provider = azurerm.platform
  for_each = local.platform_networks

  name                = each.value.name
  location            = data.azurerm_resource_group.hub.location
  resource_group_name = data.azurerm_resource_group.hub.name
  address_space       = [each.value.address_space]
  tags                = merge(local.tags, { Purpose = each.value.purpose })
}

resource "azurerm_subnet" "platform" {
  provider = azurerm.platform
  for_each = local.platform_subnets

  name                 = each.value.name
  resource_group_name  = data.azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub[each.value.network_key].name
  address_prefixes     = [each.value.address_prefix]
}

resource "azurerm_virtual_network" "spoke" {
  provider = azurerm.dev
  for_each = local.dev_networks

  name                = each.value.name
  location            = data.azurerm_resource_group.dev.location
  resource_group_name = data.azurerm_resource_group.dev.name
  address_space       = [each.value.address_space]
  tags                = merge(local.tags, { Purpose = each.value.purpose })
}

resource "azurerm_subnet" "spoke" {
  provider = azurerm.dev
  for_each = local.dev_subnets

  name                 = each.value.name
  resource_group_name  = data.azurerm_resource_group.dev.name
  virtual_network_name = azurerm_virtual_network.spoke[each.value.network_key].name
  address_prefixes     = [each.value.address_prefix]
}

resource "azurerm_route_table" "spoke" {
  provider = azurerm.dev
  for_each = local.dev_routes

  name                = each.value.route_table_name
  location            = data.azurerm_resource_group.dev.location
  resource_group_name = data.azurerm_resource_group.dev.name
  tags                = merge(local.tags, { Purpose = each.value.purpose })

  route {
    name                   = each.value.route_name
    address_prefix         = each.value.address_prefix
    next_hop_type          = each.value.next_hop_type
    next_hop_in_ip_address = each.value.next_hop_type == "VirtualAppliance" ? each.value.next_hop_in_ip_address : null
  }
}

resource "azurerm_subnet_route_table_association" "spoke" {
  provider = azurerm.dev
  for_each = local.dev_routes

  subnet_id      = azurerm_subnet.spoke[each.value.subnet_key].id
  route_table_id = azurerm_route_table.spoke[each.key].id
}

resource "azurerm_private_dns_zone" "zones" {
  provider = azurerm.platform
  for_each = local.private_dns_zones_all

  name                = each.value.name
  resource_group_name = data.azurerm_resource_group.hub.name
  tags                = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub" {
  provider = azurerm.platform
  for_each = local.private_dns_zones_all

  name                  = "link-${each.key}-hub"
  resource_group_name   = data.azurerm_resource_group.hub.name
  private_dns_zone_name = azurerm_private_dns_zone.zones[each.key].name
  virtual_network_id    = azurerm_virtual_network.hub["hub"].id
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  provider = azurerm.platform
  for_each = azurerm_virtual_network.spoke

  name                      = "peer-hub-to-${each.key}"
  resource_group_name       = data.azurerm_resource_group.hub.name
  virtual_network_name      = azurerm_virtual_network.hub["hub"].name
  remote_virtual_network_id = each.value.id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  provider = azurerm.dev
  for_each = azurerm_virtual_network.spoke

  name                      = "peer-${each.key}-to-hub"
  resource_group_name       = data.azurerm_resource_group.dev.name
  virtual_network_name      = each.value.name
  remote_virtual_network_id = azurerm_virtual_network.hub["hub"].id
  allow_forwarded_traffic   = true
}
