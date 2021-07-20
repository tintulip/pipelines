terraform {
  backend "s3" {
    bucket = "tfstate-620540024451-artifactory-temp"
    key    = "terraform.tfstate"
    region = "eu-west-2"
  }
}