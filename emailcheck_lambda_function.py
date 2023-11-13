import json


def lambda_handler(event, context):
    email_status = None

    if 'SSOUserEmail' in event and event['SSOUserEmail'] is not None and event['SSOUserEmail'].strip() != "":
        email_status = 'Valid'
    else:
        email_status = 'Invalid'

    response = {
        'statusCode': 200,
        'body': json.dumps('Execute successfully!'),
        'event': event,
        'email_status': email_status
    }

    return response
