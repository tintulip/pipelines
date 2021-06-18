resource "aws_codepipeline" "pipeline" {
  name     = "${var.name}-pipeline"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = var.artifact_store
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        ConnectionArn    = var.codestar_connection_arn
        FullRepositoryId = var.repository_name
        BranchName       = "main"
        DetectChanges    = false
      }
    }
    action {
      name             = "Policies"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["policies"]
      configuration = {
        ConnectionArn    = var.codestar_connection_arn
        FullRepositoryId = "tintulip/policies-as-code"
        BranchName       = "main"
        DetectChanges    = false
      }
    }
  }

  stage {
    name = "Build"
    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_output", "policies"]
      configuration = {
        ProjectName = aws_codebuild_project.codebuild.name
      }
    }
  }
}