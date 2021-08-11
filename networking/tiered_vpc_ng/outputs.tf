output "id" {
  value = aws_vpc.this.id
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
  private_subnet_to_subnet_ids  = { for subnet, this in aws_subnet.private : subnet => this.id }
  private_subnet_ids_per_az     = { for subnet, private_subnet_id in local.private_subnet_to_subnet_ids : lookup(local.private_subnet_to_azs, subnet) => private_subnet_id... } # group subnet_ids by AZ of subnet
  private_route_table_id_per_az = { for az, route_table in aws_route_table.private : az => route_table.id }

  public_subnet_to_subnet_ids  = { for subnet, this in aws_subnet.public : subnet => this.id }
  public_subnet_ids_per_az     = { for subnet, public_subnet_id in local.public_subnet_to_subnet_ids : lookup(local.public_subnet_to_azs, subnet) => public_subnet_id... } # group subnet_ids by AZ of subnet
  public_route_table_id_per_az = { for az, subnet_id in local.public_subnet_ids_per_az : az => aws_route_table.public.id }                                                 # Each public subnet shares the same route table
}

output "az_to_private_subnet_ids" {
  value = local.private_subnet_ids_per_az
}

output "az_to_private_route_table_id" {
  value = local.private_route_table_id_per_az
}

output "az_to_public_subnet_ids" {
  value = local.public_subnet_ids_per_az
}

output "az_to_public_route_table_id" {
  value = local.public_route_table_id_per_az
}
