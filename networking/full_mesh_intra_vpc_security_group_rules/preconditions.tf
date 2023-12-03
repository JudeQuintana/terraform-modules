locals {
  # used on all aws_security_group_rule resources to guarantee the intra vpc security group rules match their relative provider's region.
  one_provider_to_one_intra_vpc_security_group_rules_region_check = {
    condition = alltrue([
      for this in var.full_mesh_intra_vpc_security_group_rules.one.intra_vpc_security_group_rules :
      contains([local.one_region_name], this.region)
    ])
    error_message = "The Intra VPC Security Group Rule's regions for One must match the aws.one provider alias region for Full Mesh VPC Security Group Rules."
  }

  one_provider_to_one_intra_vpc_security_group_rules_account_id_check = {
    condition = alltrue([
      for this in var.full_mesh_intra_vpc_security_group_rules.one.intra_vpc_security_group_rules :
      contains([local.one_account_id], this.account_id)
    ])
    error_message = "The Intra VPC Security Group Rule's account ID for One must match the aws.one provider alias account ID for Full Mesh Intra VPC Security Group Rules."
  }

  two_provider_to_two_intra_vpc_security_group_rules_region_check = {
    condition = alltrue([
      for this in var.full_mesh_intra_vpc_security_group_rules.two.intra_vpc_security_group_rules :
      contains([local.two_region_name], this.region)
    ])
    error_message = "The Intra VPC Security Group Rule's regions for Two must match the aws.two provider alias region for Full Mesh VPC Security Group Rules."
  }

  two_provider_to_two_intra_vpc_security_group_rules_account_id_check = {
    condition = alltrue([
      for this in var.full_mesh_intra_vpc_security_group_rules.two.intra_vpc_security_group_rules :
      contains([local.two_account_id], this.account_id)
    ])
    error_message = "The Intra VPC Security Group Rule's account ID for Two must match the aws.two provider alias account ID for Full Mesh Intra VPC Security Group Rules."
  }

  three_provider_to_three_intra_vpc_security_group_rules_region_check = {
    condition = alltrue([
      for this in var.full_mesh_intra_vpc_security_group_rules.three.intra_vpc_security_group_rules :
      contains([local.three_region_name], this.region)
    ])
    error_message = "The Intra VPC Security Group Rule's regions for Three must match the aws.three provider alias region for Full Mesh VPC Security Group Rules."
  }

  three_provider_to_three_intra_vpc_security_group_rules_account_id_check = {
    condition = alltrue([
      for this in var.full_mesh_intra_vpc_security_group_rules.three.intra_vpc_security_group_rules :
      contains([local.three_account_id], this.account_id)
    ])
    error_message = "The Intra VPC Security Group Rule's account ID for Three must match the aws.three provider alias account ID for Full Mesh Intra VPC Security Group Rules."
  }
}
