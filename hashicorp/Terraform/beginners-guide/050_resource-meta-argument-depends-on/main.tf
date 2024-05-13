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

resource "aws_s3_bucket" "bucket" {
  bucket = "456788765-depends-on"
  depends_on = [ 
    aws_instance.app_server 
    ]

}


resource "aws_instance" "app_server" {
  ami           = "ami-00448a337adc93c05"
  instance_type = "t2.micro"
}

output "public_ip" {
  value = aws_instance.app_server.public_ip
  # sensitive = true
}

variable "instance_type" {
  description = "The Size of the Instance"
}
