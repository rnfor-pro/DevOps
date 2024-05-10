resource "aws_lb" "a4l_wordpress_alb" {
  name               = "A4LWORDPRESSALB"
  internal           = false  # Set to true if you only want the ALB to be accessible within the VPC
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_load_balancer.id]
  subnets            = [aws_subnet.sn_pub_a.id, aws_subnet.sn_pub_b.id, aws_subnet.sn_pub_c.id]
  ip_address_type    = "ipv4"

  tags = {
    Name = "A4LWORDPRESSALB"
  }
}


# Define the Target Group

resource "aws_lb_target_group" "a4l_wordpress_albtg" {
  name     = "A4LWORDPRESSALBTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.a4l_vpc.id

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
  }

  tags = {
    Name = "A4LWORDPRESSALBTG"
  }
}

# Define the Listener

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.a4l_wordpress_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.a4l_wordpress_albtg.arn
  }
}


# Integrate ASG with the Load Balancer

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.wordpress_asg.id
  lb_target_group_arn   = aws_lb_target_group.a4l_wordpress_albtg.arn
}


# Update the Auto Scaling Group

# resource "aws_autoscaling_group" "wordpress_asg" {
#   min_size         = 1
#   max_size         = 3
#   desired_capacity = 1

#   vpc_zone_identifier = [aws_subnet.sn_pub_a.id, aws_subnet.sn_pub_b.id, aws_subnet.sn_pub_c.id]
#   launch_template {
#     id      = aws_launch_template.wordpress_lt.id
#     version = "$Latest"
#   }

#   target_group_arns = [aws_lb_target_group.a4l_wordpress_albtg.arn]

#   tag {
#     key                 = "Name"
#     value               = "A4LWORDPRESSASG"
#     propagate_at_launch = true
#   }
# }
