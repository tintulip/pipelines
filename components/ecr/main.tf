resource "aws_ecr_repository" "ecr" {
  #tfsec:ignore:AWS093
  name                 = var.name
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
