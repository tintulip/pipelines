resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "cla-pipeline-artifacts"
  acl    = "private"
}

resource "aws_s3_bucket_policy" "codepipeline_bucket" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  policy = data.aws_iam_policy_document.codepipeline_bucket_policy.json
}

data "aws_iam_policy_document" "codepipeline_bucket_policy" {
  statement {
    actions = ["s3:GetObject"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::961889248176:role/app_deployer"]
    }

    resources = [
      "arn:aws:s3:::cla-pipeline-artifacts/*"
    ]
  }
}