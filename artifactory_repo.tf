resource "artifactory_remote_repository" "docker-remote" {
  key             = "docker-remote"
  package_type    = "docker"
  url             = "https://registry-1.docker.io"
  repo_layout_ref = "simple-default"
}