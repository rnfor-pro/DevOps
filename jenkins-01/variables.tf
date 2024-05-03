variable "aws_region" {
  default = "us-east-2"
}

variable "ami_id" {
  default = "ami-0b4750268a88e78e0"
}

variable "instance_type" {
  default = "t2.xlarge"
}

variable "key_name" {
  default = "devtf-key"
}

variable "tomcat_ami_id" {
  default = "ami-0b4750268a88e78e0"
} 

variable "tomcat_instance_type" {
  default = "t2.micro"
}

variable "tomcat_key" {
  default = "devtf-key"
}

# variable "bucket" {
#   default = ""
# }

# variable "acl" {
#   default = "private"
# }
