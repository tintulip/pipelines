'use strict'

const AWS = require('aws-sdk');
const { WebhookHandler } = require('./webhook_handler');

const ssmClient = new AWS.SSM({});
const codePipeline = new AWS.CodePipeline();

const getGitHubSecret = async () => {
  return new Promise((resolve, reject )=> {
    ssmClient.getParameter({ Name: process.env.GITHUB_SECRET_NAME, WithDecryption: true }, (err, data) => {
      if(err) {
        reject(err);
      } else {
        resolve(data.Parameter.Value);
      }
    });
  });
};

const triggerPipeline = async () => {
  return new Promise((resolve, reject) => {
    codePipeline.startPipelineExecution({ name: process.env.PIPELINE_NAME }, (err, data) => {
      if(err) {
        reject(err);
      } else {
        resolve(data.pipelineExecutionId)
      }
  })
  });
};

exports.handler = WebhookHandler(getGitHubSecret, triggerPipeline, process.env.GITHUB_REPO_FULL_NAME)