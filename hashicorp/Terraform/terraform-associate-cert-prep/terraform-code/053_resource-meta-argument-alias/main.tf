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
  region  = "us-east-1"
  alias   = "west"
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
  alias   = "east"
}

data "aws_ami" "west-amazon-linux-2" {
  provider    = aws.west
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

data "aws_ami" "east-amazon-linux-2" {
  provider    = aws.east
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "my_west_server" {
  ami           = "${data.aws_ami.west-amazon-linux-2.id}"
  instance_type = var.instance_type
  provider      = "aws.west"

  tags = {
    Name = "server-west"
  }
}

resource "aws_instance" "my_east_server" {
  ami           = "${data.aws_ami.east-amazon-linux-2.id}"
  provider      = "aws.east"
  instance_type = var.instance_type

  tags = {
    Name = "server-east"
  }
}

output "west_public_ip" {
  # value = aws_instance.app_server[1].public_ip
  value = aws_instance.my_west_server.public_ip
  # sensitive = true
}

output "east_public_ip" {
  # value = aws_instance.app_server[1].public_ip
  value = aws_instance.my_east_server.public_ip
  # sensitive = true
}

variable "instance_type" {
  default =  "t2.micro"
  description = "The Size of the Instance"
}
