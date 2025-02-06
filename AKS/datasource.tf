###############################################################################
# DATA SOURCES
###############################################################################
data "azurerm_resource_group" "this" {
  name = "corerg"
}

data "azurerm_storage_account" "keystoneloki" {
  name                = "keystoneloki"
  resource_group_name = data.azurerm_resource_group.this.name
}
###############################################################################
# RESOURCES
###############################################################################

# Generate a random integer (for demonstration; not strictly required)
resource "random_integer" "this" {
  min = 10000
  max = 5000000
}

