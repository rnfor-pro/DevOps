resource "aws_iam_role" "ipv6_workaround_role" {
  name = "ipv6_workaround_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "ipv6_workaround_policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "ec2:ModifySubnetAttribute",
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }
}


resource "aws_lambda_function" "ipv6_workaround_lambda" {
  function_name    = "ipv6_workaround_lambda"
  handler          = "lambda_function.lambda_handler"
  role             = aws_iam_role.ipv6_workaround_role.arn
  runtime          = "python3.9"
  filename         = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")
}


# Custom resource for triggering Lambda to modify subnet attributes
resource "aws_lambda_invocation" "subnet_modification" {
  function_name = aws_lambda_function.ipv6_workaround_lambda.function_name

  input = jsonencode({
    RequestType = "Create",
    ResourceProperties = {
      SubnetId = aws_subnet.sndba.id
    }
  })

  depends_on = [aws_subnet.sndba]
}
