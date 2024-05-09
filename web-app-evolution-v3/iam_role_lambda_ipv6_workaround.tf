# resource "aws_iam_role" "lambda_ipv6_workaround_role" {
#   name = "lambda_ipv6_workaround_role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = "sts:AssumeRole"
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_policy" "lambda_ipv6_workaround_policy" {
#   name = "lambda_ipv6_workaround_policy"
#   description = "IAM policy for modifying subnet attributes"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = [
#           "ec2:ModifySubnetAttribute",
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents"
#         ],
#         Resource = "*"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "lambda_ipv6_workaround_policy_attachment" {
#   role       = aws_iam_role.lambda_ipv6_workaround_role.name
#   policy_arn = aws_iam_policy.lambda_ipv6_workaround_policy.arn
# }
