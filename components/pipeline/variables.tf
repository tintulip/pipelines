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

variable "privileged_mode" {
  type    = bool
  default = false
}