import json
import boto3

# Initialize the DynamoDB client
dynamodb = boto3.client('dynamodb')

# Define the DynamoDB table name
table_name = 'ssp-table'

def lambda_handler(event, context):
    try:
        # Scan the DynamoDB table to get all items
        response = dynamodb.scan(TableName=table_name)

        # Extract the items from the response
        items = response.get('Items', [])

        # Parse the items to a JSON format
        data = [dict((key, val.get('S')) for key, val in item.items()) for item in items]

        # Respond to the API Gateway request
        return {
            'statusCode': 200,
            'body': json.dumps(data)
        }
    except Exception as e:
        # Handle any exceptions and return an error response
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
