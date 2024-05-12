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

data "aws_vpc" "main" {
  id = "vpc-04ff8032b9c93b789"
}

locals {
  ingress = [
    {
    port = "443"
    description = "HTTPS traffic"
    protocol = "tcp"
},
{
    port = "80"
    description = "HTTP traffic"
    protocol = "tcp"
}
]
}



resource "aws_security_group" "my_sg" {
  name        = "my_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = data.aws_vpc.main.id

 dynamic "ingress" {
    for_each = local.ingress
    content {
    description      = ingress.value.description
    from_port        = ingress.value.port
    to_port          = ingress.value.port
    protocol         = ingress.value.protocol
    cidr_blocks      = [data.aws_vpc.main.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
    }
 }


  egress {
    description      = "Outgoing traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }
}