output "account_id" {
  value = local.account_id
}

output "az_to_private_subnet_ids" {
  value = { for subnet_cidr, this in aws_subnet.this_private : lookup(local.private_subnet_cidr_to_az, subnet_cidr) => this.id... } # group subnet_ids by AZ of subnet
}

output "az_to_private_route_table_id" {
  value = { for az, route_table in aws_route_table.this_private : az => route_table.id }
}

locals {
  az_to_public_subnet_ids     = { for subnet_cidr, this in aws_subnet.this_public : lookup(local.public_subnet_cidr_to_az, subnet_cidr) => this.id... } # group subnet_ids by AZ of subnet
  az_to_public_route_table_id = { for az, subnet_id in local.az_to_public_subnet_ids : az => aws_route_table.this_public.id }                           # Each public subnet shares the same route table
}

output "az_to_public_subnet_ids" {
  value = local.az_to_public_subnet_ids
}

output "az_to_public_route_table_id" {
  value = local.az_to_public_route_table_id
}

locals {
  private_subnet_name_to_subnet_id = { for private_subnet_cidr, this in aws_subnet.this_private : lookup(local.private_subnet_cidr_to_subnet_name, private_subnet_cidr) => this.id }
  public_subnet_name_to_subnet_id  = { for public_subnet_cidr, this in aws_subnet.this_public : lookup(local.public_subnet_cidr_to_subnet_name, public_subnet_cidr) => this.id }
}

output "subnet_name_to_subnet_id" {
  value = merge(local.private_subnet_name_to_subnet_id, local.public_subnet_name_to_subnet_id)
}

output "default_security_group_id" {
  value = aws_vpc.this.default_security_group_id
}

output "full_name" {
  value = local.vpc_name
}

output "id" {
  value = aws_vpc.this.id
}

output "intra_vpc_security_group_id" {
  value = aws_security_group.this_intra_vpc.id
}

output "network" {
  # pass thru what is known pre-apply
  value = var.tiered_vpc.network
}

output "name" {
  value = var.tiered_vpc.name
}

output "region" {
  value = local.region_name
}
