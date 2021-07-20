
variable "artifactory_url" {
  type        = string
  description = "Base url of your artifactory instance including scheme"
}

variable "artifactory_ci_user_email" {
  type        = string
  description = "Email to register the CI user on arti"
}

variable "artifactory_ci_user_name" {
  type        = string
  description = "Username for the CI user"
  default     = "ci"
}

variable "stack_id" {
  type        = string
  description = "Id of stack, used to namespace resources and name tfstate bucket (will become tfstate-<acctid>-<yourname>)"
}
