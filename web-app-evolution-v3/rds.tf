# resource "aws_db_instance" "wordpress_db" {
#   allocated_storage    = 20
#   storage_type         = "gp2"
#   engine               = "mysql"
#   engine_version       = "5.7"
#   instance_class       = "db.t2.small"
#   name                 = "wordpressdb"
#   username             = "wpadmin"
#   password             = "wpadmin1234"
#   parameter_group_name = "default.mysql5.7"

#   vpc_security_group_ids = [aws_security_group.sg_database.id]

#   tags = {
#     Name = "WordpressDB"
#   }
# }