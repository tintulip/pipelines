data "template_file" "buildspec_deploy" {
  template = file(var.buildspec_deploy_path)
}
resource "aws_codebuild_project" "deploy_image" {
  name          = "${var.name}-deploy"
  description   = "deploys ecr image cross account"
  build_timeout = "5"

  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = var.privileged_mode

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = "eu-west-2"
    }

    environment_variable {
      name  = "AWS_BUILDER_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = "961889248176"
    }

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = var.name
    }

    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }

  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }
  }

  source {
    buildspec = data.template_file.buildspec_deploy.rendered
    type      = "CODEPIPELINE"
  }

}
