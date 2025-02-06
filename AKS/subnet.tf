resource "azurerm_subnet" "subnet1" {
  name                 = local.sanitize_name.subnet
  address_prefixes     = ["10.0.0.0/19"]
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
}