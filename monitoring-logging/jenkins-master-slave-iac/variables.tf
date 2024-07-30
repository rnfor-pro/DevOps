variable "aws_region" {
  default = "us-east-2"
}

variable "ami_id" {
  default = "ami-003932de22c285676"
}

variable "instance_type" {
  default = "t2.medium"
}

variable "key_name" {
  default = "devtf-key"
}

variable "slave_ami_id" {
  default = "ami-003932de22c285676"
} 

variable "slave_instance_type" {
  default = "t2.micro"
}

variable "slave_key_name" {
  default = "devtf-key"
}

variable "bucket" {
  default = ""
}

variable "acl" {
  default = "private"
}
