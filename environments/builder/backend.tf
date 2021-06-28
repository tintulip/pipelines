terraform {
  backend "s3" {
    bucket = "tfstate-620540024451-cla-builder-state"
    key    = "pipeline-factory/infra-pipeline.tfstate"
    region = "eu-west-2"
  }
}