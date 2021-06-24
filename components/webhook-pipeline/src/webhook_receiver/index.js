'use strict'

const AWS = require('aws-sdk');
const { WebhookHandler } = require('./webhook_handler');

const ssmClient = new AWS.SSM({
})

async function getGitHubSecret() {
  return new Promise((resolve,reject)=>{
    ssmClient.getParameter({Name: process.env.GITHUB_SECRET_NAME, WithDecryption: true},function(err,data){
      if(err) {
        reject(err);
      } else {
        resolve(data.Parameter.Value);
      }
    });
  });
} 

exports.handler = WebhookHandler(getGitHubSecret)