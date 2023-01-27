output "account_id" {
  value = local.account_id
}

output "region" {
  value = local.region_name
}

output "rule" {
  value = var.intra_vpc_security_group_rule.rule
}

output "vpcs" {
  value = var.intra_vpc_security_group_rule.vpcs
}
