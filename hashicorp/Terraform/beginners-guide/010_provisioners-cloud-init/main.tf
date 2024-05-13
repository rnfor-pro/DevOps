terraform {
  /*
  cloud {
    organization = "etech-dev"

    workspaces {
      name = "provisioners"
    }
  }
  */
    required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.24.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

data "aws_vpc" "main" {
  id = "vpc-04ff8032b9c93b789"
}

resource "aws_security_group" "sg_app_server" {
  name        = "sg_app_server"
  description = "SG for App Server"
  vpc_id      = data.aws_vpc.main.id

  ingress = [
    {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
  },
  {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["173.64.85.16/32"]
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
  }
  ]
  egress = [
  {
    description = "out bound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids = []
    security_groups = []
    self = false
  }
  ]
}


resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC389wXJDTvmKGktBB2JgX+WpU+CITonpE0LsvrrVBxy4fA1/lCKlHPYZFYJX6jJCpg5rC0mMmCwLOYyUEPQIw9VVSlfPu7KIv+ULxS7PqagaQlby7SggRnMNsl/uhWv8gE+R4MoSal3A9Gj72zTdxCcaET39QAxEr2mWbp2UF2a+iLg/0geOC69fvbSWttjxN7L+Hnmg+6EAlirvUONTPAOlEaW9xr+AXn6CoObqT3ZE9W5nP5RwLlhDqc22ArnqbGpM3D5jYm92TQ8mc+HWFRJqobm3nZzaob4b7F0E84Qrni2bMR23EODthl2E1/WW21MONPwXccBXLzrpEExp0qeVJvMfAI89DUjDXffOXwG71dzBYEQ4ok7nCJ+4gNeE55rS33YDK/iq4apx2LEMQQaS7GfMQfPGnRDXOa4bKcQsJiq2e6dBGTap+fZjVcdtI2OEr3gGPLi1J6CAW5T4tqIj1ObnwY2Rmc9Ko8eEgwk0dQptDW6jOxDaVjIGbnC+s= macbookpro@MacBooks-MBP"
}

data "template_file" "userdata" {
  template = file("./userdata.yaml")
  
}

resource "aws_instance" "app_server" {
  ami           = "ami-00448a337adc93c05"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.deployer.key_name}"
  vpc_security_group_ids = [aws_security_group.sg_app_server.id]
  user_data = data.template_file.userdata.rendered

  connection {
    type     = "ssh"
    user     = "ec2-user"
    host     = "${self.public_ip}"
    private_key = "${file("/Users/macbookpro/.ssh/terraform")}"
  }
  
  provisioner "file" {
    content     = "mars"
    destination = "/home/ec2-user/barsoon"
  }

  tags = {
    Name = "App_Server"
  }
}

output "public_ip" {
  value = aws_instance.app_server.public_ip
}


