import boto3
import json

def lambda_handler(event, context):
    region = event.get('ResourceProperties', {}).get('Region')
    if not region:
        print("Region not provided in the event")
        return {'statusCode': 400, 'body': 'Region not provided'}

    ec2 = boto3.client('ec2', region_name=region)
    subnet_id = event.get('ResourceProperties', {}).get('SubnetId')

    if event.get('RequestType') == 'Delete':
        print("Delete request processed")
        return {'statusCode': 200, 'body': json.dumps('Delete request processed successfully')}

    try:
        ec2.modify_subnet_attribute(SubnetId=subnet_id,
                                    AssignIpv6AddressOnCreation={'Value': True})
        responseData = {'SubnetId': subnet_id}
        print("Modification successful")
        return {'statusCode': 200, 'body': json.dumps(responseData)}
    except Exception as e:
        print(f"Error modifying subnet: {str(e)}")
        return {'statusCode': 400, 'body': json.dumps(str(e))}
