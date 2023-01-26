output "account_id" {
  value = local.account_id
}

output "region" {
  value = local.region_name
}

output "rule" {
  value = var.intra_vpc_security_group_rule.rule
}

output "vpc_names" {
  value = [for this in var.intra_vpc_security_group_rule.vpcs : this.name]
}

output "vpc_network_cidrs" {
  value = [for this in var.intra_vpc_security_group_rule.vpcs : this.network_cidr]
}

output "vpcs" {
  value = var.intra_vpc_security_group_rule.vpcs
}
