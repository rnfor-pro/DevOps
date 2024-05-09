# resource "aws_efs_file_system" "wordpress_efs" {
#   creation_token = "wordpress-efs"

#   tags = {
#     Name = "WordpressEFS"
#   }
# }

# resource "aws_efs_mount_target" "efs_mount" {
#   for_each           = toset(data.aws_availability_zones.available.names)
#   file_system_id     = aws_efs_file_system.wordpress_efs.id
#   subnet_id          = aws_subnet.sn_app_a.id  # Example: Mount in app subnet A
#   security_groups    = [aws_security_group.sg_efs.id]
# }
