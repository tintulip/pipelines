resource "aws_codeartifact_domain" "cla" {
  domain = "cla"
}

resource "aws_codeartifact_repository" "web_application" {
  repository = "web_application"
  domain     = aws_codeartifact_domain.cla.domain

  external_connections {
    external_connection_name = "public:maven-central"
  }
}