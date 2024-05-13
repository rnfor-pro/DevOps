Terraform Modules To Provision an EC2 that is running Apache.

Not intended for production use, just showcasing how to create a custom module on terraform registry...

```hcl
terraform {
}

provider "aws" {
  region = "us-west-2"
}

module "apache" {
  source = ".//terraform-aws-apache-example"
  vpc_id = "vpc-00000000"

  my_ip_with_cidr = "MY_OWN_IP_ADDRESS/32"

  public_key = "ssh-rsa AAAAB3......."

  instance_type = "t2.micro"

  server_name = "Apache Server"
}

output "public_ip" {
  value = module.apache.public_ip
}
```