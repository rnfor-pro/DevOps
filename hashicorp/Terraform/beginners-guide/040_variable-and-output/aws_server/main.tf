terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.25.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
}

output "public_ip" {
  value = aws_instance.app_server.public_ip
  # sensitive = true
}

variable "instance_type" {
  type        = string
  description = "The Size of the Instance"
  # sensitive   = true
  validation {
    condition     = can(regex("^t2.", var.instance_type))
    error_message = "The instance must be a t2 type EC2 instance."
  }
}
