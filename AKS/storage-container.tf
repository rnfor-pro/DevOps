resource "azurerm_storage_container" "this" {
  name                  = local.sanitize_name.storage_container
  container_access_type = "private"
  storage_account_name  = data.azurerm_storage_account.keystoneloki.name
}