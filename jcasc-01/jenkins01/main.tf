# terraform {
#   required_version = ">=0.12"
# }

resource "aws_instance" "jcasc" {
  ami = var.ami_id
  instance_type = var.instance_type
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.main.id]
  
 user_data = <<-EOT
        #!/bin/bash
        
        sudo apt-get update -y
        sudo apt-get install docker.io -y
        sudo usermod -aG docker ubuntu
        newgrp docker
        sudo chmod 777 /var/run/docker.sock

        sudo hostnamectl set-hostname docker

        bash

        EOT
        
tags    = {
  Name = "docker-engine"
}     
}

resource "aws_security_group" "main" {
  name = "jcasc_security_group"
  description = "Jenkins Configuration as Code basics"


ingress {
    from_port   = 80
    protocol    = "TCP"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    protocol    = "TCP"
    to_port     = 22
    cidr_blocks = ["173.64.85.16/32"]
  }

    ingress {
    from_port   = 8080
    protocol    = "TCP"
    to_port     = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


