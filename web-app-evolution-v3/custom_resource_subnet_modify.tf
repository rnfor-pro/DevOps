# resource "aws_cloudformation_stack" "subnet_modify" {
#   name = "subnet-modify-stack"

#   template_body = <<EOF
# Resources:
#   SubnetModification:
#     Type: Custom::SubnetModify
#     Properties:
#       ServiceToken: ${aws_lambda_function.ipv6_workaround.invoke_arn}
#       SubnetId: ${aws_subnet.sn_pub_a.id}
# EOF
# }
