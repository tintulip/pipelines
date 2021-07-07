output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = module.vpc.vpc_arn
}

output "private_subnets" {
  description = "Private subnets of VPC"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "The public subnet of the VPC"
  value       = module.vpc.public_subnets
}

output "cidr_block" {
  description = "The cidr blocks of the vpc"
  value       = module.vpc.vpc_cidr_block
}


