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

# resource "aws_s3_bucket" "example" {
#   bucket = "nfor.life"

# }

resource "aws_instance" "app_server" {
  ami           = "ami-00448a337adc93c05"
  instance_type = var.instance_type
  

  tags = {
    Name = "my_server"
  }
}

output "public_ip" {
  # value = aws_instance.app_server[1].public_ip
  value = aws_instance.app_server.public_ip
  # sensitive = true
}

variable "instance_type" {
  description = "The Size of the Instance"
  default = "t2.micro"
}
