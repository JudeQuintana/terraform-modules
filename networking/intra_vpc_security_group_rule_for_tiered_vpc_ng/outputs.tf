output "account_id" {
  value = local.account_id
}

output "region" {
  value = local.region_name
}

# using local.intra_vpc_security_group_rules instead of the resource
output "vpc_id_to_rule" {
  value = local.vpc_id_to_intra_vpc_security_group_rules
}

output "vpcs" {
  value = var.intra_vpc_security_group_rule.vpcs
}

