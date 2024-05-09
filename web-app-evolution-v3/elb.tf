# resource "aws_elb" "wordpress_elb" {
#   name               = "wordpress-elb"
#   availability_zones = data.aws_availability_zones.available.names

#   listener {
#     instance_port     = 80
#     instance_protocol = "HTTP"
#     lb_port           = 80
#     lb_protocol       = "HTTP"
#   }

#   health_check {
#     target              = "HTTP:80/"
#     interval            = 30
#     timeout             = 5
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#   }

#   tags = {
#     Name = "WordpressELB"
#   }
# }
