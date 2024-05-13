resource "aws_instance" "app_server" {
  ami           = "ami-07d07d65c47e5aa90"
  instance_type = var.instance_type

  tags = {
    Name = "App_Server-${local.project_name}"
  }
}


/*
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  #passing providers explicitely as aliases in a module: 
  #https://developer.hashicorp.com/terraform/language/modules/develop/providers#:~:text=pass%20providers%20explicitly.-,Passing%20Providers%20Explicitly,-When%20child%20modules
  providers = {
  aws = aws.use2
}
  name = "my-vpc-${local.project_name}" #
  cidr = "10.0.0.0/16"

  azs             = ["us-east-2a", "us-east-2b", "us-east-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
*/

