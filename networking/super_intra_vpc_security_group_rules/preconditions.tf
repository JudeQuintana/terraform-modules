locals {
  # used on both aws_security_group_rule.this_local and aws_security_group_rule.this_peer
  # guarantee the centralized routers match their relative provider's region.
  local_provider_to_local_intra_vpc_security_group_rules_region_check = {
    condition = alltrue(flatten(
      [for this in var.super_intra_vpc_security_group_rules.local.intra_vpc_security_group_rules :
        contains([local.local_region_name], this.region)
    ]))
    error_message = "All local Intra VPC Security Group Rule's regions must match the aws.local provider alias region for Super Intra VPC Security Group Rules."
  }

  local_provider_to_local_intra_vpc_security_group_rules_account_id_check = {
    condition = alltrue(flatten(
      [for this in var.super_intra_vpc_security_group_rules.local.intra_vpc_security_group_rules :
        contains([local.local_region_name], this.account_id)
    ]))
    error_message = "All local Intra VPC Security Group Rule's account ID must match the aws.local provider alias account ID for Super Intra VPC Security Group Rules."
  }

  peer_provider_to_peer_intra_vpc_security_group_rules_region_check = {
    condition = alltrue(flatten(
      [for this in var.super_intra_vpc_security_group_rules.peer.intra_vpc_security_group_rules :
        contains([local.peer_region_name], this.region)
    ]))
    error_message = "All peer Intra VPC Security Group Rule's regions must match the aws.peer provider alias region for Super Intra VPC Security Group Rules."
  }

  peer_provider_to_peer_intra_vpc_security_group_rules_account_id_check = {
    condition = alltrue(flatten(
      [for this in var.super_intra_vpc_security_group_rules.peer.intra_vpc_security_group_rules :
        contains([local.peer_region_name], this.account_id)
    ]))
    error_message = "All peer Intra VPC Security Group Rule's account ID must match the aws.peer provider alias account ID for Super Intra VPC Security Group Rules."
  }
}
