# ansible course : https://www.youtube.com/watch?v=sGeZm__pZ9I&list=PL2qzCKTbjutIyQAe3GglWISLnLTQLGm7e

# https://www.squadcast.com/blog/how-to-deploy-multiple-ec2-instances-in-one-go-using-terraform

resource "aws_instance" "my-machine" {
  # Creates four identical aws ec2 instances
  count = 3    
  
  # All four instances will have the same ami and instance_type
  ami = lookup(var.ec2_ami,var.region) 
  instance_type = var.instance_type # 
  key_name                    = var.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.ansible_sg.id]

  tags = {
    # The count.index allows you to launch a resource 
    # starting with the distinct index number 0 and corresponding to this instance.
    Name = "ansible-${count.index}"
  }
}

resource "aws_instance" "ansible_controller" {
  ami = lookup(var.ec2_ami,var.region) 
  instance_type = var.instance_type # 
  key_name                    = var.key_name
  associate_public_ip_address = true
  user_data                   = "${file("install_ansible.sh")}"
  vpc_security_group_ids      = [aws_security_group.ansible_sg.id]

  tags = {
    Name = "ansible-controller"
  }
}


# Ansible Security Group
resource "aws_security_group" "ansible_sg" {
  name        = "ansible-sg"
  description = "Allow Port 22, 443, and 8080"

  ingress {
    description = "Allow SSH Traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

