resource "aws_ssm_parameter" "db_user" {
  name        = "/A4L/Wordpress/DBUser"
  description = "Wordpress Database User"
  type        = "String"
  value       = "a4lwordpressuser"
}

resource "aws_ssm_parameter" "db_name" {
  name        = "/A4L/Wordpress/DBName"
  description = "Wordpress Database Name"
  type        = "String"
  value       = "a4lwordpressdb"
}

resource "aws_ssm_parameter" "db_endpoint" {
  name        = "/A4L/Wordpress/DBEndpoint"
  description = "Wordpress Endpoint Name"
  type        = "String"
  value       = "localhost"
  lifecycle {
    create_before_destroy = true  # Ensures zero downtime during resource replacement
    prevent_destroy       = true  # Prevents accidental deletion
    ignore_changes        = [
      tags,    # Ignores changes to tags made outside Terraform
    ]
  }
}

resource "aws_ssm_parameter" "db_password" {
  name        = "/A4L/Wordpress/DBPassword"
  description = "Wordpress DB Password"
  type        = "SecureString"
  value       = "4n1m4l54L1f3"
  key_id      = "alias/aws/ssm"  # Default KMS Key for SSM
}

resource "aws_ssm_parameter" "db_root_password" {
  name        = "/A4L/Wordpress/DBRootPassword"
  description = "Wordpress DBRoot Password"
  type        = "SecureString"
  value       = "4n1m4l54L1f3"
  key_id      = "alias/aws/ssm"  # Default KMS Key for SSM
}
