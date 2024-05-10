# AZ
data "aws_availability_zones" "available" {}

# VPC
resource "aws_vpc" "a4l_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "A4LVPC"
  }
}

# SUBNETS

resource "aws_subnet" "sn_pub_a" {
  vpc_id                  = aws_vpc.a4l_vpc.id
  cidr_block              = var.snpubA
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  # depends_on = [aws_instance.example]

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name = "sn-pub-A"
  }
}

# route_table_association_public_a
resource "aws_route_table_association" "rta_pub_a" {
  subnet_id      = aws_subnet.sn_pub_a.id
  route_table_id = aws_route_table.rt_public.id
}


# subnet_public_b
resource "aws_subnet" "sn_pub_b" {
  vpc_id                  = aws_vpc.a4l_vpc.id
  cidr_block              = var.snpubB
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  # depends_on = [aws_instance.example]

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name = "sn-pub-B"
  }
}

# route_table_association_public_b

resource "aws_route_table_association" "rta_pub_b" {
  subnet_id      = aws_subnet.sn_pub_b.id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_subnet" "sn_pub_c" {
  vpc_id                  = aws_vpc.a4l_vpc.id
  cidr_block              = var.snpubC
  availability_zone       = data.aws_availability_zones.available.names[2]
  map_public_ip_on_launch = true

  # depends_on = [aws_instance.example]

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name = "sn-pub-C"
  }
}

# route_table_association_public_c
resource "aws_route_table_association" "rta_pub_c" {
  subnet_id      = aws_subnet.sn_pub_c.id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_subnet" "sn_app_a" {
  vpc_id            = aws_vpc.a4l_vpc.id
  cidr_block        = var.snappA
  availability_zone = data.aws_availability_zones.available.names[0]

  # depends_on = [aws_instance.example]

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name = "sn-app-A"
  }
}

resource "aws_subnet" "sn_app_b" {
  vpc_id            = aws_vpc.a4l_vpc.id
  cidr_block        = var.snappB
  availability_zone = data.aws_availability_zones.available.names[1]

  # depends_on = [aws_instance.example]

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name = "sn-app-B"
  }
}

resource "aws_subnet" "sn_app_c" {
  vpc_id            = aws_vpc.a4l_vpc.id
  cidr_block        = var.snappC
  availability_zone = data.aws_availability_zones.available.names[2]

  # depends_on = [aws_instance.example]

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name = "sn-app-C"
  }
}

resource "aws_subnet" "sn_db_a" {
  vpc_id            = aws_vpc.a4l_vpc.id
  cidr_block        = var.sndba
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "sn-db-A"
  }
}

resource "aws_subnet" "sn_db_b" {
  vpc_id            = aws_vpc.a4l_vpc.id
  cidr_block        = var.sndbB
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "sn-db-B"
  }
}


resource "aws_subnet" "sn_db_c" {
  vpc_id            = aws_vpc.a4l_vpc.id
  cidr_block        = var.sndbc
  availability_zone = data.aws_availability_zones.available.names[2]

  tags = {
    Name = "sn-db-C"
  }
}

# SECURITY GROUPS

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

# INTERNET GATEWAY

resource "aws_internet_gateway" "a4l_igw" {
  vpc_id = aws_vpc.a4l_vpc.id

  # depends_on = [aws_instance.example]

  lifecycle {
    prevent_destroy       = false
    create_before_destroy = false
  }

  tags = {
    Name = "A4L-IGW"
  }
}

# PUBLIC ROUTE

resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.a4l_vpc.id

  tags = {
    Name = "A4L-vpc-rt-pub"
  }
}

# IAM INSTANCE PROFILE
resource "aws_iam_instance_profile" "wordpress_instance_profile" {
  name = "A4LVPC-WordpressInstanceProfile"
  role = aws_iam_role.wordpress_role.name
}

# IAM ROLE FOR WORDPRESS
resource "aws_iam_role" "wordpress_role" {
  name = "WordpressRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "WordpressRole"
  }
}

resource "aws_iam_role_policy_attachment" "wordpress_ssm" {
  role       = aws_iam_role.wordpress_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "wordpress_efs" {
  role       = aws_iam_role.wordpress_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemClientFullAccess"
}

# ROUTE IPV4 PUBLIC
resource "aws_route" "rt_pub_default_ipv4" {
  route_table_id         = aws_route_table.rt_public.id
  destination_cidr_block = var.rt_pub_default_ipv4
  gateway_id             = aws_internet_gateway.a4l_igw.id
}


# PARAMETER STORE VALUES

resource "aws_ssm_parameter" "db_user" {
  name        = "/A4L/Wordpress/DBUser"
  description = "Wordpress Database User"
  type        = "String"
  value       = "a4lwordpressuser"
}

resource "aws_ssm_parameter" "db_name" {
  name        = "/A4L/Wordpress/DBName"
  description = "Wordpress Database Name"
  type        = "String"
  value       = "a4lwordpressdb"
}

######## uncomment this before creating RDS but make sure you comment it and run terraform apply before creating the one for RDS
resource "aws_ssm_parameter" "db_endpoint" {
  name        = "/A4L/Wordpress/DBEndpoint"
  description = "Wordpress Endpoint Name"
  type        = "String"
  value       = "localhost"
# #   lifecycle {
# #     create_before_destroy = true  # Ensures zero downtime during resource replacement
# #     prevent_destroy       = true  # Prevents accidental deletion
# #     ignore_changes        = [
# #       tags,    # Ignores changes to tags made outside Terraform
# #     ]
# #   }
}

###### Parameters for RDS with RDS endpoint url. this step an only be done after creating RDS
# resource "aws_ssm_parameter" "db_endpoint" {
#   name        = "/A4L/Wordpress/DBEndpoint" # RDSEndpoint
#   description = "Wordpress Endpoint Name"
#   type        = "String"
#   value       = "a4lwordpress.cdiaord7vlsf.us-east-1.rds.amazonaws.com"

# }


resource "aws_ssm_parameter" "db_password" {
  name        = "/A4L/Wordpress/DBPassword"
  description = "Wordpress DB Password"
  type        = "SecureString"
  value       = "4n1m4l54L1f3"
  key_id      = "alias/aws/ssm"  # Default KMS Key for SSM
}

resource "aws_ssm_parameter" "db_root_password" {
  name        = "/A4L/Wordpress/DBRootPassword"
  description = "Wordpress DBRoot Password"
  type        = "SecureString"
  value       = "4n1m4l54L1f3"
  key_id      = "alias/aws/ssm"  # Default KMS Key for SSM
}

resource "aws_ssm_parameter" "file_system_id" {
  name        = "/A4L/Wordpress/EFSFSID"
  description = "Wordpress DBRoot Password"
  type        = "SecureString"
  value       = "fs-XXXXXXX"
  key_id      = "alias/aws/ssm"  
}


resource "aws_ssm_parameter" "alb_dns_name" {
  name        = "/A4L/Wordpress/ALBDNSNAME"
  description = "DNS Name of the Application Load Balancer for wordpress"
  type        = "String"
  value       = "DNS-name-of-the-load-balancer"
  key_id      = "alias/aws/ssm"  
}