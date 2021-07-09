resource "random_password" "artifactory_password" {
  length  = 16
  special = false
}

resource "artifactory_user" "ci" {
  name              = "ci"
  email             = "yusra.dahir+tintulip+ci@thoughtworks.com"
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
    repositories = [artifactory_remote_repository.docker-remote.key]

    actions {
      groups {
        name        = artifactory_group.ci-group.name
        permissions = ["read", "write"]
      }
    }
  }
}

resource "aws_secretsmanager_secret" "artifactory_password" {
  name       = "artifactory_password"
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
