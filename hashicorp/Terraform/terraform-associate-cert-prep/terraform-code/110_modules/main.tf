terraform {
}

provider "aws" {
  region = "us-west-1"
}

module "apache" {
  source = ".//terraform-aws-apache-example"
  vpc_id = "vpc-07afbae9e604e01bd"

  my_ip_with_cidr = "50.77.81.125/32"

  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC389wXJDTvmKGktBB2JgX+WpU+CITonpE0LsvrrVBxy4fA1/lCKlHPYZFYJX6jJCpg5rC0mMmCwLOYyUEPQIw9VVSlfPu7KIv+ULxS7PqagaQlby7SggRnMNsl/uhWv8gE+R4MoSal3A9Gj72zTdxCcaET39QAxEr2mWbp2UF2a+iLg/0geOC69fvbSWttjxN7L+Hnmg+6EAlirvUONTPAOlEaW9xr+AXn6CoObqT3ZE9W5nP5RwLlhDqc22ArnqbGpM3D5jYm92TQ8mc+HWFRJqobm3nZzaob4b7F0E84Qrni2bMR23EODthl2E1/WW21MONPwXccBXLzrpEExp0qeVJvMfAI89DUjDXffOXwG71dzBYEQ4ok7nCJ+4gNeE55rS33YDK/iq4apx2LEMQQaS7GfMQfPGnRDXOa4bKcQsJiq2e6dBGTap+fZjVcdtI2OEr3gGPLi1J6CAW5T4tqIj1ObnwY2Rmc9Ko8eEgwk0dQptDW6jOxDaVjIGbnC+s= macbookpro@MacBooks-MBP"

  instance_type = "t2.micro"

  server_name = "Apache Server"
}

output "subnet_id" {
 value = module.apache
 # value = [for s in data.aws_subnets.subnet_id : s.cidr_block]
}

# output "subnet_cidr_blocks" {
#   value = [for s in data.aws_subnets.example : s.cidr_block]
# }



