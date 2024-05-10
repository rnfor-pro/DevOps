# resource "aws_autoscaling_group" "wordpress_asg" {
#   min_size         = 1
#   max_size         = 3
#   desired_capacity = 1

#   vpc_zone_identifier = [aws_subnet.sn_pub_a.id, aws_subnet.sn_pub_b.id, aws_subnet.sn_pub_c.id] # Using public subnets for illustration

#   launch_template {
#     id      = aws_launch_template.wordpress_lt.id
#     version = "$Latest"
#   }

#   tag {
#     key                 = "Name"
#     value               = "A4LWORDPRESSASG"
#     propagate_at_launch = true
#   }
# }

