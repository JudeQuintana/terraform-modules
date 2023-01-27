variable "env_prefix" {
  description = "prod, stage, test"
  type        = string
}

variable "region_az_labels" {
  description = "Region and AZ names mapped to short naming conventions for labeling"
  type        = map(string)
}

variable "super_intra_vpc_security_group_rules" {
  description = "super intra vpc security group rules configuration"
  type = object({
    # security rule object to allow inbound across vpcs intra-vpc security group
    local = object({
      intra_vpc_security_group_rules = map(object({
        account_id = string
        region     = string
        rule = object({
          label     = string
          protocol  = string
          from_port = number
          to_port   = number
        })
        vpcs = map(object({
          id                          = string
          intra_vpc_security_group_id = string
          network_cidr                = string
        }))
    })) })
    peer = object({
      intra_vpc_security_group_rules = map(object({
        account_id = string
        region     = string
        rule = object({
          label     = string
          protocol  = string
          from_port = number
          to_port   = number
        })
        vpcs = map(object({
          id                          = string
          intra_vpc_security_group_id = string
          network_cidr                = string
        }))
    })) })
  })

  #validations for labels, protocol, regions, account_id
  # Local Rules

  # Local VPCs
  validation {
    condition = length(distinct(flatten([
      for this in var.super_intra_vpc_security_group_rules.local.intra_vpc_security_group_rules : this.account_id
    ]))) <= 1
    error_message = "All local Intra VPC Security Group Rules must have the same account id as each other and the aws.local provider alias."
  }

  validation {
    condition     = alltrue([for this in var.super_intra_vpc_security_group_rules.local.intra_vpc_security_group_rules : length(this.vpcs) > 1])
    error_message = "There must be at least 2 local VPCs per Intra VPC Security Group Rule."
  }
}
