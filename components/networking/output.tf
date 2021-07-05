output "private_subnets" {
  description = "The private subnet of the VPC"
  value       = module.internet_vpc.private_subnets
}

output "vpc_id" {
  description = "The id of the VPC"
  value       = module.internet_vpc.vpc_id
}