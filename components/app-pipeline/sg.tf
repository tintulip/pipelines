resource "aws_security_group" "pipeline" {
  name        = "pipeline"
  description = "Security group for the pipeline"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "pipeline" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.pipeline.id
}