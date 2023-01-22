output "rule" {
  value = merge(var.intra_vpc_security_group_rule.rule, {
    account_id = local.account_id
    region     = local.region_name
  })
}

output "vpcs" {
  value = var.intra_vpc_security_group_rule.vpcs
}
