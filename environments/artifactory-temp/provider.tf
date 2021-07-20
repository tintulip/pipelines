provider "artifactory" {
  url = var.artifactory_url
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
  default_tags {
    tags = {
      tfstack = var.stack_id
      repo    = "pipelines"
    }
  }
}

provider "random" {
}
