resource "aws_security_group" "pipeline" {
  name        = "pipeline"
  description = "Security group for the pipeline"
  vpc_id      = module.network.vpc_id
}


resource "aws_security_group_rule" "pipeline" {
  description       = "secruity group rule for the pipeline"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] #tfsec:ignore:AWS007
  security_group_id = aws_security_group.pipeline.id
}