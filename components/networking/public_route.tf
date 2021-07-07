data "aws_route_table" "public_subnet" {
  subnet_id = element(module.internet_vpc.public_subnets, 0)
}

resource "aws_route" "public_to_firewall" {
  route_table_id         = data.aws_route_table.public_subnet.route_table_id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = element(local.endpoint_id, 0)
}