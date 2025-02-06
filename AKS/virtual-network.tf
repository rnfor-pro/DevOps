resource "azurerm_virtual_network" "this" {
  name                = local.sanitize_name.virtual_network
  address_space       = ["10.0.0.0/16"]
  location            = local.region
  resource_group_name = local.resource_group_name

  tags = {
    env = local.env
  }
}