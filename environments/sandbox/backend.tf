terraform {
  backend "s3" {
    bucket = "tfstate-183042814065-cla-sandbox-state"
    key    = "pipeline-factory/infra-pipeline.tfstate"
    region = "eu-west-2"
  }
}