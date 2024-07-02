variable "env_prefix" {
  description = "prod, stage, test"
  type        = string
}

variable "region_az_labels" {
  description = "Region and AZ names mapped to short naming conventions for labeling"
  type        = map(string)
}

variable "ipv6_intra_vpc_security_group_rule" {
  description = "intra vpc security group rule configuration"
  type = object({
    # security rule object to allow inbound across vpcs intra-vpc security group
    rule = object({
      label     = string
      protocol  = string
      from_port = number
      to_port   = number
    })
    # map of tiered_vpc_ng objects
    vpcs = map(object({
      id                          = string
      intra_vpc_security_group_id = string
      name                        = string
      ipv6_network_cidr           = string
      region                      = string
      account_id                  = string
    }))
  })

  validation {
    condition     = length(distinct([for this in var.ipv6_intra_vpc_security_group_rule.vpcs : this.account_id])) <= 1
    error_message = "All VPCs must have the same account id as each other."
  }

  validation {
    condition     = length(distinct([for this in var.ipv6_intra_vpc_security_group_rule.vpcs : this.region])) <= 1
    error_message = "All VPCs must have the same region as each other."
  }

  validation {
    condition = length(distinct([
      for this in var.ipv6_intra_vpc_security_group_rule.vpcs : this.name
      ])) == length([
      for this in var.ipv6_intra_vpc_security_group_rule.vpcs : this.name
    ])
    error_message = "All VPCs must have unique names."
  }

  validation {
    condition = length(distinct([
      for this in var.ipv6_intra_vpc_security_group_rule.vpcs : this.ipv6_network_cidr
      ])) == length([
      for this in var.ipv6_intra_vpc_security_group_rule.vpcs : this.ipv6_network_cidr
    ])
    error_message = "All VPCs must have unique IPv6 network CIDRs."
  }

  validation {
    condition     = length(var.ipv6_intra_vpc_security_group_rule.vpcs) > 1
    error_message = "There must be at least 2 VPCs."
  }
}

