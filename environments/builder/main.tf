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
  source                  = "../../components/infra-pipeline"
  name                    = "workloads"
  codestar_connection_arn = aws_codestarconnections_connection.provider.arn
  repository_name         = "tintulip/workloads"
  artifact_store          = aws_s3_bucket.codepipeline_bucket.bucket
  bucket_arn              = aws_s3_bucket.codepipeline_bucket.arn
  buildspec_path          = "${path.module}/buildspecs/infra_buildspec.yml"
  privileged_mode         = true
  vpc_id                  = module.network.vpc_id
  private_subnets         = module.network.private_subnets
  security_group_ids      = [aws_security_group.pipeline.id]
}

module "app_pipeline" {
  source                  = "../../components/app-pipeline"
  name                    = "web-application"
  codestar_connection_arn = aws_codestarconnections_connection.provider.arn
  repository_name         = "tintulip/web-application"
  artifact_store          = aws_s3_bucket.codepipeline_bucket.bucket
  bucket_arn              = aws_s3_bucket.codepipeline_bucket.arn
  buildspec_path          = "${path.module}/buildspecs/app_buildspec.yml"
  buildspec_deploy_path   = "${path.module}/buildspecs/deploy_app_buildspec.yml"
  privileged_mode         = true
  vpc_id                  = module.network.vpc_id
  private_subnets         = module.network.private_subnets
  security_group_ids      = [aws_security_group.pipeline.id]
  ecr_arn                 = module.web_application_ecr.ecr_arn
  additional_codebuild_policy_arns = [
    var.artifactory_ci_password_access_policy_arn
  ]
}

module "web_application_ecr" {
  source = "../../components/ecr"
  name   = "web-application"
}