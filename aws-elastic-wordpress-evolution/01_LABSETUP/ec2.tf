resource "aws_instance" "wordpress_manual" {
  ami           = "ami-07caf09b362be10b8"
  instance_type = "t2.micro"
  user_data                   = file("a4l.sh")
  subnet_id     = aws_subnet.sn_pub_a.id
  vpc_security_group_ids = [
    # aws_security_group.a4l_vpc_sgwordpress.id  # Adjust this ID based on actual security group ID
    aws_security_group.sg_wordpress.id
  ]

  associate_public_ip_address = true # Enable Auto-assign public IP
  # ipv6_address_count = 1                # Enable Auto-assign IPv6 IP
  # ipv6_addresses = [aws_subnet.sn_pub_a.ipv6_cidr_block]  # Check if subnet is configured for IPv6

  iam_instance_profile = "A4LVPC-WordpressInstanceProfile"

  # Since the instance is not using a key pair
  key_name = ""

  credit_specification {
    cpu_credits = "standard" # Standard mode for CPU credits
  }

  tags = {
    Name = "Wordpress-Manual"
  }
}
