variable "vpc_id" {
    type = string
  description = "The ID of our vpc"
}


variable "my_ip_with_cidr" {
  type = string
  description = "My IP ith cidr e.g 50.77.81.125/32"
}

variable "public_key" {
    type = string
    description = "The public key of my EC2 instance"
}

variable "instance_type" {
    type = string
    description = "The type of Ec2 instance"
    default = "t2.micro"
  
}

variable "server_name" {
    type = string
    description = "The Ec2 instance name"
    default = "Apache Server"
  
}

