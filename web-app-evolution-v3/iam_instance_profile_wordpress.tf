resource "aws_iam_instance_profile" "wordpress_instance_profile" {
  name = "A4LVPC-WordpressInstanceProfile"
  role = aws_iam_role.wordpress_role.name
}
