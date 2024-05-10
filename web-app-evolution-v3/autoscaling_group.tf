
resource "aws_launch_template" "wordpress_lt" {
  name          = "Wordpress"
  image_id      = "ami-07caf09b362be10b8"  # Ensure this is the correct AMI ID for Wordpress
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.sg_wordpress.id]

  user_data = base64encode(file("a4l.sh"))  # Ensure the script is correctly formatted and executable
  
    iam_instance_profile {
    name = aws_iam_instance_profile.wordpress_instance_profile.name
  }

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "wordpress-LT"
    }
  }
}

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
