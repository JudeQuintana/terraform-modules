output "account_id" {
  value = local.account_id
}

output "region" {
  value = local.region_name
}

output "rule" {
  value = var.ipv6_intra_vpc_security_group_rule.rule
}

output "vpcs" {
  value = var.ipv6_intra_vpc_security_group_rule.vpcs
}
