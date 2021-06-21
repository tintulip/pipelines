# provider "aws" {
#   region = "eu-west-1"

#   # Make it faster by skipping something
#   skip_get_ec2_platforms      = true
#   skip_metadata_api_check     = true
#   skip_region_validation      = true
#   skip_credentials_validation = true

#   # skip_requesting_account_id should be disabled to generate valid ARN in apigatewayv2_api_execution_arn
#   skip_requesting_account_id = false
# }

locals {
  subdomain   = "complete-http"
}


module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  name          = "${var.name}-pipeline-webhook"
  description   = "Gateway for pipeline-triggering webhooks"
  protocol_type = "HTTP"

  create_api_domain_name = false

  default_stage_access_log_destination_arn = aws_cloudwatch_log_group.logs.arn
  default_stage_access_log_format          = "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId $context.integrationErrorMessage"

  default_route_settings = {
    detailed_metrics_enabled = true
    throttling_burst_limit   = 10
    throttling_rate_limit    = 10
  }

  integrations = {
    "POST /" = {
      lambda_arn             = module.lambda_function.lambda_function_arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 12000
    }
  }
}

resource "aws_cloudwatch_log_group" "logs" {
  name = "${var.name}-pipeline-webhook-logs"
}

module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 2.0"

  function_name = "${var.name}-pipeline-webhook"
  description   = "Trigger pipeline ${var.name} on publish event"
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  publish       = true

  source_path = [{
    path     = "${path.module}/src/webhook_receiver",
    commands = [
      "npm install",
      ":zip"
    ],
    patterns = [
      "!.*/.*\\.txt",
      "!.*/.*\\.md",
      "node_modules/.+",
    ],
  }]

  allowed_triggers = {
    AllowExecutionFromAPIGateway = {
      service    = "apigateway"
      source_arn = "${module.api_gateway.apigatewayv2_api_execution_arn}/$default/POST/"
    }
  }
}
