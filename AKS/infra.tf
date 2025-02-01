###############################################################################
# TERRAFORM & PROVIDER CONFIG
###############################################################################
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.75.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.1.0"
    }
  }
}

provider "azurerm" {
  features {}

  # OPTIONAL: If needed, specify your subscription
  subscription_id = var.subscription_id
}

###############################################################################
# VARIABLES
###############################################################################
variable "subscription_id" {
  type        = string
  description = "Azure subscription ID for resource deployment"
  default     = "00000000-0000-0000-0000-000000000000"
}

###############################################################################
# DATA SOURCES
###############################################################################
data "azurerm_resource_group" "this" {
  # Use the existing resource group 'corerg'
  name = "corerg"
}

# ---------------------------------------------------------------------------
# ********* NEW DATA SOURCE for existing Storage Account 'keystoneloki' ******
# ---------------------------------------------------------------------------
data "azurerm_storage_account" "keystoneloki" {
  name                = "keystoneloki"
  resource_group_name = data.azurerm_resource_group.this.name
}

###############################################################################
# LOCALS
###############################################################################
locals {
  env                 = "dev"
  region              = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name

  eks_name     = "demo"
  eks_version  = "1.27"
}

###############################################################################
# RESOURCES
###############################################################################

resource "random_integer" "this" {
  min = 10000
  max = 5000000
}

# ----------------------------------------------------------------------------
# REMOVED: We are no longer creating a Storage Account
# resource "azurerm_storage_account" "this" {
#   name                     = "devtest${random_integer.this.result}"
#   resource_group_name      = local.resource_group_name
#   location                 = local.region
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
# }
# ----------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# ********* Updated to reference data source for existing storage account ****
# ---------------------------------------------------------------------------
resource "azurerm_storage_container" "this" {
  name                  = "test"
  container_access_type = "private"
  storage_account_name  = data.azurerm_storage_account.keystoneloki.name
}

resource "azurerm_user_assigned_identity" "base" {
  name                = "base"
  location            = local.region
  resource_group_name = local.resource_group_name
}

resource "azurerm_role_assignment" "base" {
  scope                = data.azurerm_resource_group.this.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.base.principal_id
}

# ---------------------------------------------------------------------------
# ********* Updated 'scope' to use existing storage account data source ******
# ---------------------------------------------------------------------------
resource "azurerm_role_assignment" "dev_test" {
  scope                = data.azurerm_storage_account.keystoneloki.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.base.principal_id
}

resource "azurerm_virtual_network" "this" {
  name                = "main"
  address_space       = ["10.0.0.0/16"]
  location            = local.region
  resource_group_name = local.resource_group_name

  tags = {
    env = local.env
  }
}

resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  address_prefixes     = ["10.0.0.0/19"]
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
}

resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2"
  address_prefixes     = ["10.0.32.0/19"]
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
}

resource "azurerm_kubernetes_cluster" "this" {
  name                = "${local.env}-${local.eks_name}"
  location            = local.region
  resource_group_name = local.resource_group_name
  dns_prefix          = "devaks1"

  kubernetes_version        = local.eks_version
  automatic_channel_upgrade = "stable"
  private_cluster_enabled   = false
  node_resource_group       = "${local.resource_group_name}-${local.env}-${local.eks_name}"

  # It's in Preview
  # api_server_access_profile {
  #   vnet_integration_enabled = true
  #   subnet_id                = azurerm_subnet.subnet1.id
  # }

  # For production, change to "Standard"
  sku_tier = "Free"

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  network_profile {
    network_plugin = "azure"
    dns_service_ip = "10.0.64.10"
    service_cidr   = "10.0.64.0/19"
  }

  default_node_pool {
    name                 = "general"
    vm_size              = "Standard_D2_v2"
    vnet_subnet_id       = azurerm_subnet.subnet1.id
    orchestrator_version = local.eks_version
    type                 = "VirtualMachineScaleSets"
    enable_auto_scaling  = true
    node_count           = 1
    min_count            = 1
    max_count            = 10

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

  depends_on = [
    azurerm_role_assignment.base
  ]
}

resource "azurerm_kubernetes_cluster_node_pool" "spot" {
  name                  = "spot"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = "Standard_DS2_v2"
  vnet_subnet_id        = azurerm_subnet.subnet1.id
  orchestrator_version  = local.eks_version
  priority              = "Spot"
  spot_max_price        = -1
  eviction_policy       = "Delete"

  enable_auto_scaling = true
  node_count          = 1
  min_count           = 1
  max_count           = 10

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
