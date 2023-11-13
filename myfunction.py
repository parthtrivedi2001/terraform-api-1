const AWS = require("aws-sdk");

exports.handler = async (event, context) => {
  const dynamo = new AWS.DynamoDB.DocumentClient();
  const dbName = "Test-Project-Table";
  const headers = {
    "Content-Type": "application/json"
  };

  try {
    let body;
    let statusCode = 200;

    switch (event.routeKey) {
      case "DELETE /projects/{id}":
        await dynamo
          .delete({
            TableName: dbName,
            Key: {
              ProjectUUID: event.pathParameters.id
            }
          })
          .promise();
        body = `Deleted project ${event.pathParameters.id}`;
        break;
      case "GET /projects/{id}":
        body = await dynamo
          .get({
            TableName: dbName,
            Key: {
              id: event.pathParameters.id
            }
          })
          .promise();
        break;
      case "GET /projects":
        body = await dynamo.scan({ TableName: dbName }).promise();
        break;
      case "PUT /projects":
        const requestJSON = JSON.parse(event.body);
        const {
          ProjectUUID,
          ProjectDescription,
          ProjectName,
          BudgetaryProperties,
          ProjectAccount,
          ProjectDocuments,
          ProjectLifecycle,
          ProjectLocation,
          ProjectResponsibility
        } = requestJSON;

        await dynamo
          .put({
            TableName: dbName,
            Item: {
              ProjectUUID: ProjectUUID,
              ProjectDescription,
              ProjectName,
              BudgetaryProperties,
              ProjectAccount,
              ProjectDocuments,
              ProjectLifecycle,
              ProjectLocation,
              ProjectResponsibility
            }
          })
          .promise();
        body = `Put project ${ProjectUUID}`;
        break;
      default:
        throw new Error(`Unsupported route: "${event.routeKey}"`);
    }

    body = JSON.stringify(body);

    return {
      statusCode,
      body,
      headers
    };
  } catch (err) {
    const statusCode = 400;
    const body = err.message;

    return {
      statusCode,
      body,
      headers
    };
  }
};
