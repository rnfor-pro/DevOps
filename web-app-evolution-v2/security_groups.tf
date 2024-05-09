# Security Group for Wordpress Instances
resource "aws_security_group" "sg_wordpress" {
  name        = "SGWordpress"
  description = "Control access to Wordpress Instance(s)"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow HTTP IPv4 IN"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Wordpress SG"
  }
}


# Security Group for Database
resource "aws_security_group" "sg_database" {
  name        = "SGDatabase"
  description = "Control access to Database"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "Allow MySQL IN"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_wordpress.id]
  }

  tags = {
    Name = "Database SG"
  }
}


# Security Group for Load Balancer
resource "aws_security_group" "sg_load_balancer" {
  name        = "SGLoadBalancer"
  description = "Control access to Load Balancer"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow HTTP IPv4 IN"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Load Balancer SG"
  }
}


# Security Group for EFS (Elastic File System)
resource "aws_security_group" "sg_efs" {
  name        = "SGEFS"
  description = "Control access to EFS"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "Allow NFS/EFS IPv4 IN"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_wordpress.id]
  }

  tags = {
    Name = "EFS SG"
  }
}


