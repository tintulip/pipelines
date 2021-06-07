resource "aws_ecr_repository" "ecr" {
  name                 = var.name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository_policy" "allow_workload_to_pull" {
  repository = aws_ecr_repository.ecr.name
  policy     = data.aws_iam_policy_document.workload_fetch.json
}

data "aws_iam_policy_document" "workload_fetch" {
  statement {
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:DescribeRepositories",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages"
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.workload_aws_account_id}:root"]
    }
  }
}