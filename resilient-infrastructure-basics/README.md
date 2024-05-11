# Corresponding Terraform Code

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "custom_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "Custom-VPC"
  }
}

resource "aws_subnet" "public_subnet" {
  count                   = 3
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"][count.index]
  map_public_ip_on_launch = true
  availability_zone       = ["us-east-1a", "us-east-1b", "us-east-1c"][count.index]
  tags = {
    Name = "Public-Subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.custom_vpc.id
  tags = {
    Name = "Custom-IGW"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.custom_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "Public-Route-Table"
  }
}

resource "aws_route_table_association" "a" {
  count          = length(aws_subnet.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "web_sg" {
  name        = "WebApp-SG"
  description = "Security group for web application"
  vpc_id      = aws_vpc.custom_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "WebApp-SG"
  }
}

resource "aws_launch_template" "webapp_lt" {
  name_prefix   = "webapp-lt-"
  image_id      = "ami-0c55b159cbfafe1f0"  # Example AMI ID for Amazon Linux 2
  instance_type = "t2.micro"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.web_sg.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "MyWebApp-Instance"
    }
  }
}

resource "aws_lb" "web_lb" {
  name               = "MyWebApp-LB"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.public_subnet.*.id
  security_groups    = [aws_security_group.web_sg.id]

  enable_deletion_protection = false

  tags = {
    Name = "MyWebApp-LB"
  }
}

resource "aws_lb_target_group" "web_tg" {
  name     = "MyWebApp-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.custom_vpc.id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    matcher             = "200"
  }

  tags = {
    Name = "MyWebApp-TG"
  }
}

resource "aws_autoscaling_group" "web_asg" {
  launch_template {
    id      = aws_launch_template.webapp_lt.id
    version = "$Latest"
  }

  min_size         = 1
  max_size         = 4
  desired_capacity = 2
  vpc_zone_identifier = aws_subnet.public_subnet.*.id

  target_group_arns = [aws_lb_target_group.web_tg.arn]

  tag {
    key                 = "Name"
    value               = "MyWebApp-ASG"
    propagate_at_launch = true
  }
}

# Deletion Steps in Terraform

To delete the setup, simply run `terraform destroy`. Ensure all resources are managed by Terraform and listed in your configuration for successful and complete deletion. Double-check your Terraform state files and logs to verify that no resources are left undeleted.