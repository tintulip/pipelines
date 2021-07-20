resource "artifactory_remote_repository" "docker-remote" {
  key             = "docker-remote"
  package_type    = "docker"
  url             = "https://registry-1.docker.io"
  repo_layout_ref = "simple-default"
}

resource "artifactory_remote_repository" "gradle-remote" {
  key             = "gradle-remote"
  package_type    = "gradle"
  url             = "https://jcenter.bintray.com"
  repo_layout_ref = "maven-2-default"
}

resource "artifactory_remote_repository" "pypi-remote" {
  key               = "pypi-remote"
  package_type      = "pypi"
  url               = "https://files.pythonhosted.org"
  repo_layout_ref   = "simple-default"
  pypi_registry_url = "https://pypi.org"
}