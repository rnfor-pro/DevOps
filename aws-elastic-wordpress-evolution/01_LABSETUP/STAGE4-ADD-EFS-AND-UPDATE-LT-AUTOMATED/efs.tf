#############Either use this#######################
# resource "aws_efs_file_system" "wordpress_efs" {
#   creation_token = "wordpress-efs"

#   tags = {
#     Name = "A4L-WORDPRESS-CONTENT"
#   }
# }

# resource "aws_efs_mount_target" "efs_mount" {
#   for_each           = toset(data.aws_availability_zones.available.names)
#   file_system_id     = aws_efs_file_system.wordpress_efs.id
#   subnet_id          = aws_subnet.sn_app_a.id  # Example: Mount in app subnet A
#   security_groups    = [aws_security_group.sg_efs.id]
# }
#############END HERE#######################



#############OR THIS#######################
resource "aws_efs_file_system" "a4l_wordpress_content" {
  creation_token   = "A4L-WORDPRESS-CONTENT"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = false # Typically, you would set this to true in production for security

  tags = {
    Name = "A4L-WORDPRESS-CONTENT"
  }

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
}

# Mount targets in each Availability Zone
resource "aws_efs_mount_target" "efs_mount_a" {
  file_system_id  = aws_efs_file_system.a4l_wordpress_content.id
  subnet_id       = aws_subnet.sn_app_a.id
  security_groups = [aws_security_group.sg_efs.id]

  # availability_zone_name = "us-east-1a"
}

resource "aws_efs_mount_target" "efs_mount_b" {
  file_system_id  = aws_efs_file_system.a4l_wordpress_content.id
  subnet_id       = aws_subnet.sn_app_b.id
  security_groups = [aws_security_group.sg_efs.id]

  # availability_zone_name = "us-east-1b"
}

resource "aws_efs_mount_target" "efs_mount_c" {
  file_system_id  = aws_efs_file_system.a4l_wordpress_content.id
  subnet_id       = aws_subnet.sn_app_c.id
  security_groups = [aws_security_group.sg_efs.id]

  # availability_zone_name = "us-east-1c"
}

#############END HERE#######################