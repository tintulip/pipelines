resource "random_password" "artifactory_password" {
  length  = 32
  special = false
}

resource "artifactory_user" "ci" {
  name              = var.artifactory_ci_user_name
  email             = var.artifactory_ci_user_email
  groups            = [artifactory_group.ci-group.name]
  password          = random_password.artifactory_password.result
  disable_ui_access = true
}

resource "artifactory_group" "ci-group" {
  name             = "ci"
  description      = "Group for machine users"
  admin_privileges = false
}

resource "artifactory_permission_target" "ci-permission" {
  name = "ci-permission"

  repo {
    repositories = [artifactory_remote_repository.docker-remote.key, artifactory_remote_repository.gradle-remote.key, artifactory_remote_repository.pypi-remote.key]

    actions {
      groups {
        name        = artifactory_group.ci-group.name
        permissions = ["read", "write"]
      }
    }
  }
}

resource "aws_secretsmanager_secret" "artifactory_password" {
  name       = "${var.stack_id}/artifactory_password"
  kms_key_id = aws_kms_key.artifactory_key.id
}

resource "aws_secretsmanager_secret_version" "artifactory" {
  secret_id     = aws_secretsmanager_secret.artifactory_password.id
  secret_string = random_password.artifactory_password.result
}

resource "aws_kms_key" "artifactory_key" {
  description             = "KMS key for the artifactory machine user password"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_alias" "artifactory_key" {
  name          = "alias/${var.stack_id}/artifactory-key"
  target_key_id = aws_kms_key.artifactory_key.key_id
}

data "aws_iam_policy_document" "artifactory_ci_password_access" {
  statement {
    actions = [
      "kms:Decrypt",
    ]
    resources = [
      aws_kms_key.artifactory_key.arn
    ]
  }
  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      aws_secretsmanager_secret.artifactory_password.arn
    ]
  }
}

resource "aws_iam_policy" "artifactory_ci_password_access" {
  name        = "artifactory_ci_password_access"
  description = "Allow access to the Artifactory ci user password via secretsmanager"
  policy      = data.aws_iam_policy_document.artifactory_ci_password_access.json
}

resource "github_actions_organization_secret" "artifactory_username" {
  secret_name     = "ARTIFACTORY_CI_USERNAME"
  visibility      = "private"
  plaintext_value = var.artifactory_ci_user_name
}
resource "github_actions_organization_secret" "artifactory_password" {
  secret_name     = "ARTIFACTORY_CI_PASSWORD"
  visibility      = "private"
  plaintext_value = random_password.artifactory_password.result
}