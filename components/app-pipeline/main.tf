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
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build"]
      configuration = {
        ProjectName = aws_codebuild_project.codebuild.name
      }
    }
  }

  stage {
    name = "PreProd_Deploy"

    action {
      name             = "push-preprod-image"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      run_order        = 1
      input_artifacts  = ["source_output"]
      output_artifacts = ["preprod"]
      configuration = {
        ProjectName = aws_codebuild_project.deploy_image.name
      }
    }

    action {
      name            = "deploy-to-preprod"
      role_arn        = "arn:aws:iam::961889248176:role/app_deployer"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      version         = "1"
      run_order       = 2
      input_artifacts = ["source_output", "preprod"]
      configuration = {
        ApplicationName                = var.name
        DeploymentGroupName            = var.name
        TaskDefinitionTemplateArtifact = "preprod"
        TaskDefinitionTemplatePath     = "taskdef.json"
        AppSpecTemplateArtifact        = "preprod"
        AppSpecTemplatePath            = "appspec.yaml"
        Image1ArtifactName             = var.name
        Image1ContainerName            = "IMAGE1_NAME"
      }
    }
  }
}