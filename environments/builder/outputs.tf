output "encrypted_github_actions_secret_key" {
  value = module.codepipeline_user.encrypted_secret_key
}

output "github_actions_access_key" {
  value = module.codepipeline_user.access_key
}