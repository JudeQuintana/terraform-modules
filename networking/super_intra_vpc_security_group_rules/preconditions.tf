locals {
  # used on both aws_security_group_rule.this_local and aws_security_group_rule.this_peer
  # guarantee the centralized routers match their relative provider's region.
  local_provider_to_local_vpcs_region_check = {
    condition = alltrue(flatten(
      [for this in var.super_intra_vpc_security_group_rules.local.intra_vpc_security_group_rules :
        contains([local.local_region_name], this.region)
    ]))
    error_message = "All VPC regions must match the aws.local provider alias region for Super Intra VPC Security Group Rules."
  }

  peer_provider_to_peer_vpcs_region_check = {
    condition = alltrue(flatten(
      [for this in var.super_intra_vpc_security_group_rules.peer.intra_vpc_security_group_rules :
        contains([local.peer_region_name], this.region)
    ]))
    error_message = "All VPC regions must match the aws.peer provider alias region for Super Intra VPC Security Group Rules."
  }

  local_provider_to_local_intra_vpc_sg_rule_region_check = {
    condition = alltrue(
      [for this in var.super_intra_vpc_security_group_rules.local.intra_vpc_security_group_rules :
        contains([local.local_region_name], this.region)
    ])
    error_message = "All Intra VPC Security Group Rules regions must match the aws.local provider alias region for Super Intra VPC Security Group Rules."
  }

  peer_provider_to_peer_intra_vpc_sg_rule_region_check = {
    condition = alltrue(
      [for this in var.super_intra_vpc_security_group_rules.peer.intra_vpc_security_group_rules :
        contains([local.peer_region_name], this.region)
    ])
    error_message = "All Intra VPC Security Group Rules regions must match the aws.peer provider alias region for Super Intra VPC Security Group Rules."
  }
}
