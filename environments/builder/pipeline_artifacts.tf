resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "cla-pipeline-artifacts"
  acl    = "private"
}