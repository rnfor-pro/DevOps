terraform { 
    cloud {
    organization = "etech-dev"
    workspaces {
      name = "learn-terraform-cloud-migrate"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.21.0"
    }
  }
}


locals {
  project_name = "Nfor"
}



# terraform {
#   cloud {
#     organization = "ORGANIZATION-NAME"
#     workspaces {
#       name = "learn-terraform-cloud-migrate"
#     }
#   }
#}


