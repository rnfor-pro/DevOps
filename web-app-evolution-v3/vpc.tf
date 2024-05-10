resource "aws_vpc" "a4l_vpc" {
  cidr_block           = var.vpc_cidr_block 
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "A4LVPC"
  }
}

