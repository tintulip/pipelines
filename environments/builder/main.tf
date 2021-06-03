locals {
  environment = "builder"
}

data "aws_caller_identity" "builder" {}

module "state_bucket" {
  source      = "../../components/remote-state-bucket"
  bucket_name = "cla-${local.environment}-state"
}

module "network" {
  source      = "../../components/networking"
  owner       = "governance"
  account_id  = data.aws_caller_identity.builder.account_id
  environment = local.environment
}

module "infra_pipeline" {
  source                  = "../../components/pipeline"
  name                    = "workloads"
  codestar_connection_arn = aws_codestarconnections_connection.provider.arn
  repository_name         = "tintulip/workloads"
  artifact_store          = aws_s3_bucket.codepipeline_bucket.bucket
  bucket_arn              = aws_s3_bucket.codepipeline_bucket.arn
  buildspec_path          = "${path.module}/buildspecs/infra_buildspec.yml"
}

module "app_pipeline" {
  source                  = "../../components/pipeline"
  name                    = "web-application"
  codestar_connection_arn = aws_codestarconnections_connection.provider.arn
  repository_name         = "tintulip/web-application"
  artifact_store          = aws_s3_bucket.codepipeline_bucket.bucket
  bucket_arn              = aws_s3_bucket.codepipeline_bucket.arn
  buildspec_path          = "${path.module}/buildspecs/app_buildspec.yml"
  privileged_mode         = true
}

module "web_application_ecr" {
  source = "../../components/ecr"
  name   = "web-application"
}