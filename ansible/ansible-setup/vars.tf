# Creating a Variable for ami of type map


variable "ec2_ami" {
  type = map

  default = {
    us-west-2 = "ami-0c7843ce70e666e51"
    us-east-2 = "ami-0f30a9c3a48f3fa79"
  }
}

# Creating a Variable for region

variable "region" {
  description = "Ec2 instance region"
  type = string
  default = "us-east-2"
}



# Creating a Variable for instance_type
variable "instance_type" {    
  type = string
  default = "t2.micro"
}

variable "key_name" {
  type = string
  description = "Ec2 private key name"
  default = "devtf-key"
}