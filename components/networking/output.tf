output "private_subnets" {
  description = "The private subnet of the VPC"
  value       = module.internet_vpc.private_subnets
}

output "public_subnets" {
  description = "The public subnet of the VPC"
  value       = module.internet_vpc.public_subnets
}

output "vpc_id" {
  description = "The id of the VPC"
  value       = module.internet_vpc.vpc_id
}