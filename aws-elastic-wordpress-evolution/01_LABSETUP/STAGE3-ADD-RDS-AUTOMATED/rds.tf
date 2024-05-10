resource "aws_db_instance" "wordpress_db" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0.32"
  instance_class       = "db.t3.micro" # Adjust as necessary for the desired performance and cost
  identifier           = "a4lwordpress"
  db_name              = "a4lwordpressdb"
  username             = "a4lwordpressuser"
  password             = "4n1m4l54L1f3"
  db_subnet_group_name = aws_db_subnet_group.wordpress_db_subnet_group.name
  parameter_group_name = "default.mysql8.0"
  availability_zone    = "us-east-1a"
  publicly_accessible  = false
  skip_final_snapshot  = true # Important for testing environments, consider changing for production

  # Set backup retention to 0 days to not retain any automated backups
  backup_retention_period = 0

  vpc_security_group_ids = [aws_security_group.sg_database.id]

  tags = {
    Name = "WordpressDB"
  }
}


# rds_subnet_group

resource "aws_db_subnet_group" "wordpress_db_subnet_group" {
  name       = "wordpress-db-subnet-group"
  subnet_ids = [aws_subnet.sn_db_a.id, aws_subnet.sn_db_b.id, aws_subnet.sn_db_c.id]

  tags = {
    Name = "WordPressRDSSubNetGroup"
  }
}


