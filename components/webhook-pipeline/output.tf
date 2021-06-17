output "pipeline_arn" {
  value = aws_codepipeline.pipeline.arn
}

output "webhook_url" {
  value = aws_codepipeline_webhook.webhook.url
}