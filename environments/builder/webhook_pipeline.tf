
module "webhook_pipeline" {
  source                  = "../../components/webhook-pipeline"
  name                    = "webhook-test"
  codestar_connection_arn = aws_codestarconnections_connection.provider.arn
  repository_name         = "tintulip/webhook-test"
  artifact_store          = aws_s3_bucket.codepipeline_bucket.bucket
  bucket_arn              = aws_s3_bucket.codepipeline_bucket.arn
  buildspec_path          = "${path.module}/buildspecs/webhook_test_buildspec.yml"
  privileged_mode         = true
}

resource "aws_iam_service_linked_role" "codestar-notifications" {
  aws_service_name = "codestar-notifications.amazonaws.com"
}
