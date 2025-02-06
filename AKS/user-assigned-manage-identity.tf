resource "azurerm_user_assigned_identity" "base" {
  name                = local.sanitize_name.user_assigned_identity
  location            = local.region
  resource_group_name = local.resource_group_name
}