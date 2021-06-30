// import handler from "./index"
const { sign }  = require("@octokit/webhooks-methods");

const { WebhookHandler } = require('./webhook_handler');
const { deploymentPayload } = require('./test_fixtures')


const stubGetGitHubSecret = () => {
  return Promise.resolve("fakeSecret")
}
const failingGetGitHubSecret = () => {
  ({}).doesNotExists();
}
const nullTriggerPipeline = () => {}

test('succeeds for deployment with valid signature', async () => {

  const handler = WebhookHandler(stubGetGitHubSecret, nullTriggerPipeline, "Codertocat/Hello-World")
  const deploymentPayloadString = JSON.stringify(deploymentPayload)
  const signature = await sign("fakeSecret", deploymentPayloadString);
  const lambdaPayload = {
    headers:{
      "x-github-delivery":"123e4567-e89b-12d3-a456-426614174000",
      "x-github-event":"deployment",
      "x-hub-signature-256":signature
    },
    body: deploymentPayloadString,
  }
  expect((await  handler(lambdaPayload)).statusCode).toBe(200);
});

test('succeeds for deployment with valid signature and base64 encoded body', async () => {

  const handler = WebhookHandler(stubGetGitHubSecret, nullTriggerPipeline, "Codertocat/Hello-World")
  const deploymentPayloadString = JSON.stringify(deploymentPayload)
  const signature = await sign("fakeSecret", deploymentPayloadString);
  const lambdaPayload = {
    headers:{
      "x-github-delivery":"123e4567-e89b-12d3-a456-426614174000",
      "x-github-event":"deployment",
      "x-hub-signature-256":signature
    },
    body: Buffer.from(deploymentPayloadString).toString('base64'),
    isBase64Encoded: true,
  }
  expect((await  handler(lambdaPayload)).statusCode).toBe(200);
});

test('fails with default status code 500 when error occurs', async () => {

  const handler = WebhookHandler(failingGetGitHubSecret, nullTriggerPipeline, "Codertocat/Hello-World")
  const deploymentPayloadString = JSON.stringify(deploymentPayload)
  const signature = await sign("fakeSecret", deploymentPayloadString);
  const lambdaPayload = {
    headers:{
      "x-github-delivery":"123e4567-e89b-12d3-a456-426614174000",
      "x-github-event":"deployment",
      "x-hub-signature-256":signature
    },
    body:deploymentPayloadString
  }
  expect((await  handler(lambdaPayload)).statusCode).toBe(500);
});

test('triggers pipeline for deployment called promote on main branch from expected repo', async () => {
  const spy = {
    called: false
  }
  const spyTriggerPipeline = async () => {
    spy.called = true;
    return Promise.resolve("spy")
  }
  const handler = WebhookHandler(stubGetGitHubSecret, spyTriggerPipeline, "my/repo")

  const payload = { ...deploymentPayload}
  payload.repository.full_name = "my/repo";
  payload.repository.ref = "main";
  payload.deployment.environment = "promote";
  const deploymentPayloadString = JSON.stringify(payload)
  const signature = await sign("fakeSecret", deploymentPayloadString);
  const lambdaPayload = {
    headers:{
      "x-github-delivery":"123e4567-e89b-12d3-a456-426614174000",
      "x-github-event":"deployment",
      "x-hub-signature-256":signature
    },
    body: deploymentPayloadString,
  }

  await  handler(lambdaPayload);
  expect(spy.called).toBe(true);
});

test('does not trigger pipeline for deployment on non-main branch', async () => {
  const spy = {
    called: false
  }
  const spyTriggerPipeline = async () => {
    spy.called = true;
    return Promise.resolve("spy")
  }
  const handler = WebhookHandler(stubGetGitHubSecret, spyTriggerPipeline, "my/repo")

  const payload = { ...deploymentPayload}
  payload.repository.full_name = "my/repo";
  payload.repository.ref = "master";
  payload.deployment.environment = "promote";
  const deploymentPayloadString = JSON.stringify(payload)
  const signature = await sign("fakeSecret", deploymentPayloadString);
  const lambdaPayload = {
    headers:{
      "x-github-delivery":"123e4567-e89b-12d3-a456-426614174000",
      "x-github-event":"deployment",
      "x-hub-signature-256":signature
    },
    body: deploymentPayloadString,
  }

  await  handler(lambdaPayload);
  expect(spy.called).toBe(false);
});

test('does not trigger pipeline for deployment on unexpected repo', async () => {
  const spy = {
    called: false
  }
  const spyTriggerPipeline = async () => {
    spy.called = true;
    return Promise.resolve("spy")
  }
  const handler = WebhookHandler(stubGetGitHubSecret, spyTriggerPipeline, "my/repo")

  const payload = { ...deploymentPayload}
  payload.repository.full_name = "my/some-other-repo";
  payload.repository.ref = "main";
  payload.deployment.environment = "promote";
  const deploymentPayloadString = JSON.stringify(payload)
  const signature = await sign("fakeSecret", deploymentPayloadString);
  const lambdaPayload = {
    headers:{
      "x-github-delivery":"123e4567-e89b-12d3-a456-426614174000",
      "x-github-event":"deployment",
      "x-hub-signature-256":signature
    },
    body: deploymentPayloadString,
  }

  await  handler(lambdaPayload);
  expect(spy.called).toBe(false);
});

test('does not trigger pipeline for deployment on deployment not called promote', async () => {
  const spy = {
    called: false
  }
  const spyTriggerPipeline = async () => {
    spy.called = true;
    return Promise.resolve("spy")
  }
  const handler = WebhookHandler(stubGetGitHubSecret, spyTriggerPipeline, "my/repo")

  const payload = { ...deploymentPayload}
  payload.repository.full_name = "my/repo";
  payload.repository.ref = "main";
  payload.deployment.environment = "gh-pages";
  const deploymentPayloadString = JSON.stringify(payload)
  const signature = await sign("fakeSecret", deploymentPayloadString);
  const lambdaPayload = {
    headers:{
      "x-github-delivery":"123e4567-e89b-12d3-a456-426614174000",
      "x-github-event":"deployment",
      "x-hub-signature-256":signature
    },
    body: deploymentPayloadString,
  }

  await  handler(lambdaPayload);
  expect(spy.called).toBe(false);
});


test('yields error on pipeline start failure', async () => {
  const failingTriggerPipeline = async () => {
    return Promise.reject(new Error("intentionally failing pipeline start"));
  }
  const handler = WebhookHandler(stubGetGitHubSecret, failingTriggerPipeline, "my/repo")

  const payload = { ...deploymentPayload}
  payload.repository.full_name = "my/repo";
  payload.repository.ref = "main";
  payload.deployment.environment = "promote";
  const deploymentPayloadString = JSON.stringify(payload)
  const signature = await sign("fakeSecret", deploymentPayloadString);
  const lambdaPayload = {
    headers:{
      "x-github-delivery":"123e4567-e89b-12d3-a456-426614174000",
      "x-github-event":"deployment",
      "x-hub-signature-256":signature
    },
    body: deploymentPayloadString,
  }

  expect((await  handler(lambdaPayload)).statusCode).toBe(500);
});