resource "aws_iam_instance_profile" "wordpress_instance_profile" {
  name = "WordpressInstanceProfile"
  role = aws_iam_role.wordpress_role.name
}
