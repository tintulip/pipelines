'use strict'
const { Webhooks } = require("@octokit/webhooks");

exports.WebhookHandler = (getGitHubSecret) => { 
  return async (event, context) => {
    // webhooks.on("error", handleSignatureVerificationError);
    try {
      
      const webhooks = new Webhooks({
        secret: await getGitHubSecret()
      });
      
      const webhooksProcessing = await webhooks.verifyAndReceive({
          id: event.headers["x-github-delivery"],
          name: event.headers["x-github-event"],
          payload: event.body,
          signature: event.headers["x-hub-signature-256"],
      })

      return formatResponse(webhooksProcessing)

    } catch(error) {
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
    "statusCode": error.statusCode,
    "headers": {
      "Content-Type": "text/plain",
      "x-amzn-ErrorType": error.code
    },
    "isBase64Encoded": false,
    "body": error.code + ": " + error.message
  }
  return response
}