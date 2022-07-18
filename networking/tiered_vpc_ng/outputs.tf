output "account_id" {
  value = local.account_id
}

output "region" {
  value = local.region_name
}

output "id" {
  value = aws_vpc.this.id
}

output "full_name" {
  value = local.vpc_name
}

output "network" {
  # pass thru what is known pre-apply
  value = var.tier.network
}

output "default_security_group_id" {
  value = aws_vpc.this.default_security_group_id
}

output "intra_vpc_security_group_id" {
  value = aws_security_group.intra_vpc.id
}

locals {
  az_to_private_subnet_ids     = { for subnet, this in aws_subnet.private : lookup(local.private_subnet_to_az, subnet) => this.id... } # group subnet_ids by AZ of subnet
  az_to_private_route_table_id = { for az, route_table in aws_route_table.private : az => route_table.id }

  az_to_public_subnet_ids     = { for subnet, this in aws_subnet.public : lookup(local.public_subnet_to_az, subnet) => this.id... } # group subnet_ids by AZ of subnet
  az_to_public_route_table_id = { for az, subnet_id in local.az_to_public_subnet_ids : az => aws_route_table.public.id }            # Each public subnet shares the same route table
}

output "az_to_private_subnet_ids" {
  value = local.az_to_private_subnet_ids
}

output "az_to_private_route_table_id" {
  value = local.az_to_private_route_table_id
}

output "az_to_public_subnet_ids" {
  value = local.az_to_public_subnet_ids
}

output "az_to_public_route_table_id" {
  value = local.az_to_public_route_table_id
}
