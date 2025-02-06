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

# We are NOT creating a new storage account; referencing an existing one:
resource "azurerm_storage_container" "this" {
  name                  = "test-${var.deployment_id}"
  container_access_type = "private"
  storage_account_name  = data.azurerm_storage_account.keystoneloki.name
}

# User-Assigned Managed Identity (UAMI)
resource "azurerm_user_assigned_identity" "base" {
  name                = "base-${var.deployment_id}"
  location            = local.region
  resource_group_name = local.resource_group_name
}

resource "azurerm_virtual_network" "this" {
  name                = "main-${var.deployment_id}"
  address_space       = ["10.0.0.0/16"]
  location            = local.region
  resource_group_name = local.resource_group_name

  tags = {
    env = local.env
  }
}

resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1-${var.deployment_id}"
  address_prefixes     = ["10.0.0.0/19"]
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
}

resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2-${var.deployment_id}"
  address_prefixes     = ["10.0.32.0/19"]
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
}

###############################################################################
# DISABLE AUTOSCALING IN THE AKS CLUSTER
###############################################################################
resource "azurerm_kubernetes_cluster" "this" {
  name                = "${local.env}-${local.aks_name}"
  location            = local.region
  resource_group_name = local.resource_group_name
  dns_prefix          = "devaks1-${var.deployment_id}"

  kubernetes_version        = local.aks_version
  automatic_channel_upgrade = "stable"
  private_cluster_enabled   = false
  node_resource_group       = "${local.resource_group_name}-${local.env}-${local.aks_name}"

  sku_tier                  = "Free"  # For production, "Standard"
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  network_profile {
    network_plugin = "azure"
    dns_service_ip = "10.0.64.10"
    service_cidr   = "10.0.64.0/19"
  }

  default_node_pool {
    name                 = "general-${var.deployment_id}"
    vm_size              = "Standard_D2_v2"
    vnet_subnet_id       = azurerm_subnet.subnet1.id
    orchestrator_version = local.aks_version

    node_count = 2

    type = "VirtualMachineScaleSets"

    node_labels = {
      role = "general"
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.base.id]
  }

  tags = {
    env = local.env
  }

  lifecycle {
    ignore_changes = [default_node_pool[0].node_count]
  }
}

###############################################################################
# DISABLE AUTOSCALING IN THE ADDITIONAL NODE POOL
###############################################################################
resource "azurerm_kubernetes_cluster_node_pool" "spot" {
  name = substr(
    replace(
      lower("spot${var.deployment_id}"), # Remove hyphens and convert to lowercase
      "/[^a-z0-9]/",                     # Remove any remaining invalid characters
      ""
    ),
    0, 12                                # Truncate to 12 characters
  )
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = "Standard_DS2_v2"
  vnet_subnet_id        = azurerm_subnet.subnet1.id
  orchestrator_version  = local.aks_version
  priority              = "Spot"
  spot_max_price        = -1
  eviction_policy       = "Delete"

  node_count = 1

  node_labels = {
    role                                    = "spot"
    "kubernetes.azure.com/scalesetpriority" = "spot"
  }

  node_taints = [
    "spot:NoSchedule",
    "kubernetes.azure.com/scalesetpriority=spot:NoSchedule"
  ]

  tags = {
    env = local.env
  }

  lifecycle {
    ignore_changes = [node_count]
  }
}