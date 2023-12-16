output "account_id" {
  value = local.account_id
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

output "name" {
  value = var.tiered_vpc.name
}

output "network_cidr" {
  # pass thru what is known pre-apply
  value = var.tiered_vpc.network_cidr
}

output "private_route_table_ids" {
  value = [for this in aws_route_table.this_private : this.id]
}

output "private_subnet_cidrs" {
  value = flatten([for this in var.tiered_vpc.azs : this.private_subnets[*].cidr])
}

output "private_subnet_name_to_subnet_id" {
  value = { for this in aws_subnet.this_private : lookup(local.private_subnet_cidr_to_subnet_name, this.cidr_block) => this.id }
}

output "public_route_table_ids" {
  value = [aws_route_table.this_public.id] # Each public subnet across AZs shares the same route table
}

output "public_subnet_cidrs" {
  value = flatten([for this in var.tiered_vpc.azs : this.public_subnets[*].cidr])
}

output "public_special_subnet_ids" {
  value = [for this in local.public_az_to_special_subnet_cidr : lookup(aws_subnet.this_public, this).id]
}

output "public_subnet_name_to_subnet_id" {
  value = { for this in aws_subnet.this_public : lookup(local.public_subnet_cidr_to_subnet_name, this.cidr_block) => this.id }
}

output "region" {
  value = local.region_name
}
