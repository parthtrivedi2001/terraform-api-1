import boto3
import random
from botocore.exceptions import ClientError

def lambda_handler(event, context):
    email_status = ''
    dynamodb = boto3.client('dynamodb')
    table_name = 'account-email-list'
    desired_status = 'FREE'

    try:
        response = dynamodb.scan(
            TableName=table_name,
            FilterExpression='EmailStatus = :EmailStatus',
            ExpressionAttributeValues={':EmailStatus': {'S': desired_status}}
        )

        # Extract email IDs from the DynamoDB response
        email_ids = [item['AccountEmail']['S'] for item in response['Items']]

        if email_ids:
            email_status = 'Valid'
            selected_email = email_ids[0]

            # Update the status of the selected email to 'PENDING'
            response = dynamodb.update_item(
                TableName=table_name,
                Key={
                    'AccountEmail': {'S': selected_email}
                },
                UpdateExpression='SET EmailStatus = :s',
                ExpressionAttributeValues={
                    ':s': {'S': 'PENDING'}
                }
            )

            # Update the event with the selected email
            event['event']['AccountEmail'] = selected_email
            event['event']['SSOUserEmail'] = selected_email

            return {
                'statusCode': 200,
                'body': event,
                'email_status': email_status
            }
        else:
            email_status = 'Invalid'
            return {
                'statusCode': 404,
                'body': 'No available email found.',
                'email_status': email_status
            }
    except Exception
