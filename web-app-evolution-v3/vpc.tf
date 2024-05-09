resource "aws_vpc" "a4l_vpc" {
  cidr_block           = "10.16.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "A4LVPC"
  }
}
