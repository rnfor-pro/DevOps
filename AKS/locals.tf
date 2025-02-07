
###############################################################################
# LOCALS
###############################################################################
locals {
  env                 = "dev"
  region              = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  aks_version         = "1.27"

  # Naming logic for all resources
  sanitize_name = {
    # AKS Cluster
    aks_cluster = substr(
      replace(
        lower("${local.env}-aks-${var.deployment_id}"),
        "/[^a-z0-9-]/",
        ""
      ),
      0, 63 # AKS cluster name max length
    )

    # DNS Prefix for AKS
    dns_prefix = substr(
      replace(
        lower("${local.env}-dns-${var.deployment_id}"),
        "/[^a-z0-9-]/",
        ""
      ),
      0, 54 # DNS prefix max length
    )

    # Node Pool
    node_pool = substr(
      replace(
        lower("${local.env}-pool-${var.deployment_id}"),
        "/[^a-z0-9-]/",
        ""
      ),
      0, 12 # Node pool name max length
    )

        # Spot Node Pool
    spot_node_pool = substr(
      replace(
        lower("spot${var.deployment_id}"),
        "/[^a-z0-9-]/",
        ""
      ),
      0, 12 # Node pool name max length
    )

    # Storage Container
    storage_container = substr(
      replace(
        lower("${local.env}-container-${var.deployment_id}"),
        "/[^a-z0-9-]/",
        ""
      ),
      0, 63 # Storage container name max length
    )

    # User-Assigned Managed Identity
    user_assigned_identity = substr(
      replace(
        lower("${local.env}-identity-${var.deployment_id}"),
        "/[^a-z0-9-]/",
        ""
      ),
      0, 24 # UAMI name max length
    )

    # Virtual Network
    virtual_network = substr(
      replace(
        lower("${local.env}-vnet-${var.deployment_id}"),
        "/[^a-z0-9-]/",
        ""
      ),
      0, 64 # Virtual network name max length
    )

    # Subnet
    subnet = substr(
      replace(
        lower("${local.env}-subnet-${var.deployment_id}"),
        "/[^a-z0-9-]/",
        ""
      ),
      0, 80 # Subnet name max length
    )
  }
}

