resource "aws_security_group" "sg_wordpress" {
  vpc_id = aws_vpc.a4l_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic"
  }

  tags = {
    Name = "SG-Wordpress"
  }
}

resource "aws_security_group" "sg_database" {
  vpc_id = aws_vpc.a4l_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_wordpress.id]
    description     = "Allow MySQL access from Wordpress"
  }

  tags = {
    Name = "A4LVPC-SGDatabase"
  }
}


# SG LB

resource "aws_security_group" "sg_load_balancer" {
  vpc_id = aws_vpc.a4l_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic"
  }

  tags = {
    Name = "SG-LoadBalancer"
  }
}

# SG EFS

resource "aws_security_group" "sg_efs" {
  vpc_id = aws_vpc.a4l_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_wordpress.id]
    description     = "Allow NFS/EFS access from Wordpress instances"
  }

  tags = {
    Name = "A4LVPC-SGEFS"
  }
}
