provider "artifactory" {
  api_key = var.artifactory_api_key
  url     = "https://tintulip.jfrog.io"
}

terraform {
  required_providers {
    artifactory = {
      source  = "registry.terraform.io/jfrog/artifactory"
      version = "~> 2.2"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
  }
  required_version = ">= 0.15"
}

provider "aws" {
  region = "eu-west-2"
}

provider "random" {
}
