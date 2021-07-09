terraform {
  backend "s3" {
    bucket   = "tfstate-620540024451-artifactory"
    key      = "artifactory/builder.tfstate"
    region   = "eu-west-2"
  }
}