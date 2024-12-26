output "account_id" {
  value = local.account_id
}

output "region" {
  value = local.region_name
}

output "default_security_group_id" {
  value = aws_vpc.this.default_security_group_id
}

output "full_name" {
  value = local.vpc_full_name
}

output "id" {
  value = aws_vpc.this.id
}

output "intra_vpc_security_group_id" {
  value = aws_security_group.this_intra_vpc.id
}

output "name" {
  value = var.tiered_vpc.name
}

output "network_cidr" {
  value = var.tiered_vpc.ipv4.network_cidr
}

output "secondary_cidrs" {
  value = var.tiered_vpc.ipv4.secondary_cidrs
}

output "ipv6_network_cidr" {
  value = var.tiered_vpc.ipv6.network_cidr
}

output "ipv6_secondary_cidrs" {
  value = var.tiered_vpc.ipv6.secondary_cidrs
}

output "private_route_table_ids" {
  value = [for this in aws_route_table.this_private : this.id]
}

output "private_subnet_cidrs" {
  value = local.private_subnet_cidrs
}

output "private_ipv6_subnet_cidrs" {
  value = local.private_ipv6_subnet_cidrs
}

output "private_subnet_name_to_subnet_id" {
  value = { for this in aws_subnet.this_private : lookup(local.private_subnet_cidr_to_subnet_name, this.cidr_block) => this.id }
}

output "public_route_table_ids" {
  value = [for this in aws_route_table.this_public : this.id]
}

output "public_subnet_cidrs" {
  value = local.public_subnet_cidrs
}

output "public_ipv6_subnet_cidrs" {
  value = local.public_ipv6_subnet_cidrs
}

output "public_special_subnet_ids" {
  value = [for this in local.public_az_to_special_subnet_cidr : lookup(aws_subnet.this_public, this).id]
}

output "private_special_subnet_ids" {
  value = [for this in local.private_az_to_special_subnet_cidr : lookup(aws_subnet.this_private, this).id]
}

output "public_subnet_name_to_subnet_id" {
  value = { for this in aws_subnet.this_public : lookup(local.public_subnet_cidr_to_subnet_name, this.cidr_block) => this.id }
}

output "public_natgw_az_to_eip" {
  value = { for az, this in aws_eip.this_public : az => this.public_ip }
}

output "isolated_route_table_ids" {
  value = [for this in aws_route_table.this_isolated : this.id]
}

output "isolated_subnet_cidrs" {
  value = local.isolated_subnet_cidrs
}

output "isolated_ipv6_subnet_cidrs" {
  value = local.isolated_ipv6_subnet_cidrs
}

output "isolated_subnet_name_to_subnet_id" {
  value = { for this in aws_subnet.this_isolated : lookup(local.isolated_subnet_cidr_to_subnet_name, this.cidr_block) => this.id }
}

output "centralized_egress_private" {
  value = var.tiered_vpc.ipv4.centralized_egress.private
}

output "centralized_egress_central" {
  value = var.tiered_vpc.ipv4.centralized_egress.central
}

