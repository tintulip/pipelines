variable "name" {
  type = string
}

variable "codestar_connection_arn" {
  type = string
}

variable "repository_name" {
  type = string
}

variable "artifact_store" {
  type = string
}

variable "bucket_arn" {
  type = string
}

variable "buildspec_path" {
  type = string
}

variable "buildspec_deploy_path" {
  type = string
}

variable "privileged_mode" {
  type    = bool
  default = false
}

variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "ecr_arn" {
  type = string
}

variable "additional_codebuild_policy_arns" {
  type        = list(string)
  description = "arns of addidional IAM policies to be attached to the codebuild execution role"
}