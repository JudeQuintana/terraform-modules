output "one" {
  value = {
    account_id = local.one_account_id
    region     = local.one_region_name
    rules      = [for this in var.full_mesh_intra_vpc_security_group_rules.one.intra_vpc_security_group_rules : this.rule]
  }
}

output "two" {
  value = {
    account_id = local.two_account_id
    region     = local.two_region_name
    rules      = [for this in var.full_mesh_intra_vpc_security_group_rules.two.intra_vpc_security_group_rules : this.rule]
  }
}

output "three" {
  value = {
    account_id = local.three_account_id
    region     = local.three_region_name
    rules      = [for this in var.full_mesh_intra_vpc_security_group_rules.three.intra_vpc_security_group_rules : this.rule]
  }
}
