# Jenkins Master EC2 Instance
resource "aws_instance" "jenkins_ec2" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  user_data                   = file("install_jenkins.sh")

  tags = {
    Name = "CICD-project"
  }
}

# Jenkins Security Group
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow Port 22, 443, and 8080"

  ingress {
    description = "Allow SSH Traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS Traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow 8080 Traffic"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow traffic on port 9000 for SonarQube "
    from_port   = 9000
    to_port     = 9000
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

# Jenkins Slave EC2 Instances
resource "aws_instance" "tomcat" {
  ami                         = var.tomcat_ami_id
  instance_type               = var.tomcat_instance_type
  key_name                    = var.tomcat_key
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  user_data                   = file("install_tomcat.sh")

  tags = {
    Name = "tomcat"
  }
}

# # S3 Bucket for CI/CD
# resource "aws_s3_bucket" "my_s3_bucket" {
#   bucket = var.bucket

#   tags = {
#     Name = "CICD-project"
#   }
# }

# # S3 Bucket ACL
# resource "aws_s3_bucket_acl" "s3_bucket_acl" {
#   bucket = aws_s3_bucket.my_s3_bucket.id
#   acl    = var.acl
# }

# # S3 Bucket Ownership Controls
# resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
#   bucket = aws_s3_bucket.my_s3_bucket.id
#   rule {
#     object_ownership = "ObjectWriter"
#   }
# }

