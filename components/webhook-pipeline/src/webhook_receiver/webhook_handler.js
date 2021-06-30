'use strict'
const { Webhooks } = require("@octokit/webhooks");


const makeDeploymentHandler = (triggerPipeline, repoFullName) => async ({payload}) => {
  if(repoFullName === payload.repository.full_name &&
    "main" === payload.deployment.ref &&
    "promote" === payload.deployment.environment) {
      return triggerPipeline();
    }
};

exports.WebhookHandler = (getGitHubSecret, triggerPipeline, repoFullName) => { 
  return async (event, context) => {
    try {
      
      const webhooks = new Webhooks({
        secret: await getGitHubSecret()
      });

      webhooks.on("deployment", makeDeploymentHandler(triggerPipeline, repoFullName));

      return await webhooks.verifyAndReceive({
          id: event.headers["x-github-delivery"],
          name: event.headers["x-github-event"],
          payload: event.isBase64Encoded ? Buffer.from(event.body, 'base64').toString() : event.body,
          signature: event.headers["x-hub-signature-256"],
      }).then(formatResponse)
        .catch(formatError);

    } catch(error) {
        console.log(error)
        return formatError(error)
      }
    }
}

const formatResponse = (body) => {
  var response = {
    "statusCode": 200,
    "headers": {
      "Content-Type": "application/json"
    },
    "isBase64Encoded": false,
    "multiValueHeaders": { 
      "X-Custom-Header": ["My value", "My other value"],
    },
    "body": JSON.stringify(body)
  }
  return response
}

const formatError = (error) => {
  var response = {
    "statusCode": error.statusCode || 500,
    "headers": {
      "Content-Type": "text/plain",
      "x-amzn-ErrorType": error.code
    },
    "isBase64Encoded": false,
    "body": error.code + ": " + error.message
  }
  return response
}


