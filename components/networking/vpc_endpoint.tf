resource "aws_security_group_rule" "allow_ingress_vpc_endpoints" {
  description       = "Allow traffic to the VPC endpoints from the web-application"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.services_to_vpc_endpoints.id
  cidr_blocks       = [module.internet_vpc.cidr_block]
}

resource "aws_security_group" "services_to_vpc_endpoints" {
  name        = "services_to_vpc_endpoints"
  description = "Allow ingress traffic to vpc endpoints"
  vpc_id      = module.internet_vpc.vpc_id
}

data "aws_vpc_endpoint_service" "s3" {
  service_type = "Gateway"
  service      = "s3"
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.internet_vpc.vpc_id
  service_name      = data.aws_vpc_endpoint_service.s3.service_name
  vpc_endpoint_type = "Gateway"
}

data "aws_route_table" "private" {
  subnet_id = element(module.internet_vpc.private_subnets, 0)
}

resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  route_table_id  = data.aws_route_table.private.route_table_id
}

data "aws_prefix_list" "private_s3" {
  prefix_list_id = aws_vpc_endpoint.s3.prefix_list_id
}

data "aws_vpc_endpoint_service" "logs" {
  service = "logs"
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id            = module.internet_vpc.vpc_id
  service_name      = data.aws_vpc_endpoint_service.logs.service_name
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.services_to_vpc_endpoints.id]
  subnet_ids         = module.internet_vpc.private_subnets

  private_dns_enabled = true
}

data "aws_vpc_endpoint_service" "ecr_api" {
  service = "ecr.api"
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id            = module.internet_vpc.vpc_id
  service_name      = data.aws_vpc_endpoint_service.ecr_api.service_name
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.services_to_vpc_endpoints.id]
  subnet_ids         = module.internet_vpc.private_subnets

  private_dns_enabled = true
}

data "aws_vpc_endpoint_service" "ecr_dkr" {
  service = "ecr.dkr"
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id            = module.internet_vpc.vpc_id
  service_name      = data.aws_vpc_endpoint_service.ecr_dkr.service_name
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.services_to_vpc_endpoints.id]
  subnet_ids         = module.internet_vpc.private_subnets

  private_dns_enabled = true
}

data "aws_vpc_endpoint_service" "sts" {
  service = "sts"
}

resource "aws_vpc_endpoint" "sts" {
  vpc_id            = module.internet_vpc.vpc_id
  service_name      = data.aws_vpc_endpoint_service.sts.service_name
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.services_to_vpc_endpoints.id]
  subnet_ids         = module.internet_vpc.private_subnets

  private_dns_enabled = true
}

data "aws_vpc_endpoint_service" "ecs" {
  service = "ecs"
}

resource "aws_vpc_endpoint" "ecs" {
  vpc_id            = module.internet_vpc.vpc_id
  service_name      = data.aws_vpc_endpoint_service.ecs.service_name
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.services_to_vpc_endpoints.id]
  subnet_ids         = module.internet_vpc.private_subnets

  private_dns_enabled = true
}