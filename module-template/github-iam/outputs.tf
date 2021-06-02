output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "role_arn" {
  value = aws_iam_role.role.arn
}

output "role_id" {
  value = aws_iam_role.role.id
}

output "encrypted_secret_key" {
  value = aws_iam_access_key.user_key.encrypted_secret
}

output "access_key" {
  value = aws_iam_access_key.user_key.id
}