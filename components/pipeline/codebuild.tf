data "template_file" "buildspec" {
  template = file(var.buildspec_path)
}

resource "aws_codebuild_project" "codebuild" {
  name          = "${var.name}-build"
  description   = "applies terraform in deployment account"
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
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }
  }

  source {
    buildspec = data.template_file.buildspec.rendered
    type      = "CODEPIPELINE"
  }

}

resource "aws_iam_role" "codebuild" {
  name = "${var.name}-codebuild"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "codebuild" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "*"
    ]
  }
  statement {
    actions = [
      "s3:GetObject*",
    ]

    resources = [
      "${var.bucket_arn}",
      "${var.bucket_arn}/*"
    ]
  }
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    resources = [
      "arn:aws:iam::961889248176:role/infrastructure_pipeline"
    ]
  }
}

resource "aws_iam_role_policy" "codebuild" {
  role = aws_iam_role.codebuild.name
  policy = data.aws_iam_policy_document.codebuild.json
}
