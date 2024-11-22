// Update versions as appropriate for time of reading
terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "3.12.0"
    }
  }
}

# terraform {
#   required_version = ">= 1.2.1"

#   required_providers {
#     azurerm = {
#       source  = "hashicorp/azurerm"
#       version = "~> 3.0"
#     }

#   }
