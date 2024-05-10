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

# rds_subnet_group

# resource "aws_db_subnet_group" "wordpress_db_subnet_group" {
#   name       = "wordpress-db-subnet-group"
#   subnet_ids = [aws_subnet.sn_db_a.id, aws_subnet.sn_db_b.id, aws_subnet.sn_db_c.id]

#   tags = {
#     Name = "WordpressDBSubnetGroup"
#   }
# }



