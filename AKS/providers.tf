###############################################################################
# TERRAFORM & PROVIDER CONFIG
###############################################################################
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12.0"
    }
  }
}

provider "azurerm" {
  features {}

  # OPTIONAL: If needed, specify your subscription
  subscription_id = var.subscription_id
  skip_provider_registration = true
}

