output "pipeline_arn" {
  value = aws_codepipeline.pipeline.arn
}

output "webhook_url" {
  value = module.api_gateway.default_apigatewayv2_stage_invoke_url
}