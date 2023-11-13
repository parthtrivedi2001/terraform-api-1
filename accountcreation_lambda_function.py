import json
import boto3
 
def lambda_handler(event, context):
    # TODO implement
    print(event)
    dynamodb = boto3.client('dynamodb')

    # Specify the table name
    table_name = 'aft-request-lambda'
    #Table for the emails dynamodb
    table_name_for_email = 'account-email-list'

    # Perform the scan operation
    response = dynamodb.scan(TableName=table_name)
    # Retrieve the scanned items
    items = response['Items']
    # Continue scanning if LastEvaluatedKey is present
    while 'LastEvaluatedKey' in response:
        response = dynamodb.scan(ExclusiveStartKey=response['LastEvaluatedKey'])
        items.extend(response['Items'])
 
    for item in response['Items']:
        account_name = item['AccountName']['S']
        account_email = item['AccountEmail']['S']
        account_name_from_event = event['detail']['serviceEventDetails']['createManagedAccountStatus']['account']['accountName']
        account_id_from_event = event['detail']['serviceEventDetails']['createManagedAccountStatus']['account']['accountId']
        account_status_from_event = event['detail']['serviceEventDetails']['createManagedAccountStatus']['state']
        print(account_status_from_event)
        if account_name == account_name_from_event:
 
                update_expression=""
                expression_attribute_values=""
 
                if account_status_from_event=='SUCCEEDED':
                # Define the update expression and attribute values
                    update_expression = "SET AccountId = :id,  AccountStatus = :status"
                    expression_attribute_values = {
                            ":id": {"S": account_id_from_event},
                            ":status": {"S": account_status_from_event}
                    }
                    print(update_expression)
                    print(expression_attribute_values)
                    print("scucceded")
                    response = dynamodb.update_item(
                        TableName=table_name_for_email,
                        Key={
                            'AccountEmail': {'S': account_email}
                        },
                        UpdateExpression='SET EmailStatus = :s',
                        ExpressionAttributeValues={
                            ':s': {'S': 'USED'}  # replace 'USED' with the new status you want to set
                        })
                    # Update the item in the DynamoDB table
                elif account_status_from_event=='FAILED':
                # Define the update expression and attribute values
                    update_expression = "SET AccountId = :id,  AccountStatus = :status"
                    expression_attribute_values = {
                            ":id": {"S": ""},
                            ":status": {"S": account_status_from_event}
                    }
                    print(update_expression)
                    print(expression_attribute_values)
                    print("FAILED")

                    response = dynamodb.update_item(
                        TableName=table_name_for_email,
                        Key={
                            'AccountEmail': {'S': account_email}
                        },
                        UpdateExpression='SET EmailStatus = :s',
                        ExpressionAttributeValues={
                            ':s': {'S': 'FREE'}  # replace 'USED' with the new status you want to set
                        })

                response = dynamodb.update_item(
                            TableName = table_name,
                            Key={'AccountEmail': {'S': account_email}},
                            UpdateExpression=update_expression,
                            ExpressionAttributeValues=expression_attribute_values
                        )

 
    print(event['detail']['serviceEventDetails']['createManagedAccountStatus']['account']['accountName'])