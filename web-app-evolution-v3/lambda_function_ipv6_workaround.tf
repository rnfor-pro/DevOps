# resource "aws_lambda_function" "ipv6_workaround" {
#   function_name = "ipv6_workaround_lambda"
#   handler       = "index.lambda_handler"
#   runtime       = "python3.8"

#   role          = aws_iam_role.lambda_ipv6_workaround_role.arn

#   code {
#     zip_file = <<EOF
# import json
# import boto3
# import cfnresponse

# def lambda_handler(event, context):
#     ec2 = boto3.client('ec2')
#     if event['RequestType'] == 'Create' or event['RequestType'] == 'Update':
#         ec2.modify_subnet_attribute(SubnetId=event['ResourceProperties']['SubnetId'], AssignIpv6AddressOnCreation={'Value': True})
#         response_data = {'Status': 'SUCCESS'}
#         cfnresponse.send(event, context, cfnresponse.SUCCESS, response_data, "CustomResourcePhysicalID")
#     elif event['RequestType'] == 'Delete':
#         cfnresponse.send(event, context, cfnresponse.SUCCESS, {}, "CustomResourcePhysicalID")
# EOF
#   }

#   timeout = 30
# }
