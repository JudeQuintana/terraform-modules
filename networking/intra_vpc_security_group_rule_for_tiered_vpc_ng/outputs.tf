output "account_id" {
  value = local.account_id
}

output "region" {
  value = local.region_name
}

# using local.intra_vpc_security_group_rules instead of the resource
# because i have access to the label directly
output "all" {
  value = [for this in local.intra_vpc_security_group_rules : this]
}

