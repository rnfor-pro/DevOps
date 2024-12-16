// Update versions as appropriate for time of reading
terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "3.12.0"
    }
  }
}

provider "grafana" {
  url  = var.grafana_endpoint
  auth = var.grafana_service_account_api_key
}

