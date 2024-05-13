terraform {
  cloud {
    organization = "etech-dev"

    workspaces {
      name = "vcs-terraform"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket
}

module "apache" {
  source          = "rnfor-pro/apache-example/aws"
  version         = "1.1.0"
  vpc_id          = var.vpc_id
  my_ip_with_cidr = var.my_ip_with_cidr
  public_key      = var.public_key
  instance_type   = var.instance_type
  server_name     = var.server_name
}

output "public_ip" {
  value = module.apache.public_ip
}
