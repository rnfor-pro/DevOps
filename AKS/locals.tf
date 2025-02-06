
###############################################################################
# LOCALS
###############################################################################
locals {
  env                 = "dev"
  region              = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  aks_name            = "demo-${var.deployment_id}"
  aks_version         = "1.27"
}

