variable "env_prefix" {
  description = "prod, stage, test"
  type        = string
}

variable "region_az_labels" {
  description = "Region and AZ names mapped to short naming conventions for labeling"
  type        = map(string)
}

variable "ipv6_super_intra_vpc_security_group_rules" {
  description = "super intra vpc security group rules configuration"
  type = object({
    # security rule object to allow inbound across vpcs intra-vpc security group
    local = object({
      ipv6_intra_vpc_security_group_rules = map(object({
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
          ipv6_network_cidr           = string
          ipv6_secondary_cidrs        = list(string)
        }))
    })) })
    peer = object({
      ipv6_intra_vpc_security_group_rules = map(object({
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
          ipv6_network_cidr           = string
          ipv6_secondary_cidrs        = list(string)
        }))
    })) })
  })

  validation {
    condition = length(distinct([
      for this in var.ipv6_super_intra_vpc_security_group_rules.local.ipv6_intra_vpc_security_group_rules : this.region
    ])) <= 1
    error_message = "All local Intra VPC Security Group Rules must have the same region as each other and the aws.local provider alias for Super Intra VPC Security Group Rules."
  }

  validation {
    condition = length(distinct([
      for this in var.ipv6_super_intra_vpc_security_group_rules.local.ipv6_intra_vpc_security_group_rules : this.account_id
    ])) <= 1
    error_message = "All local Intra VPC Security Group Rules must have the same account id as each other and the aws.local provider alias for Super Intra VPC Security Group Rules."
  }

  validation {
    condition     = alltrue([for this in var.ipv6_super_intra_vpc_security_group_rules.local.ipv6_intra_vpc_security_group_rules : length(this.vpcs) > 1])
    error_message = "There must be at least 2 local VPCs per local Intra VPC Security Group Rule."
  }

  # Peer
  validation {
    condition = length(distinct([
      for this in var.ipv6_super_intra_vpc_security_group_rules.peer.ipv6_intra_vpc_security_group_rules : this.region
    ])) <= 1
    error_message = "All peer Intra VPC Security Group Rules must have the same region as each other and the aws.peer provider alias for Super Intra VPC Security Group Rules."
  }

  validation {
    condition = length(distinct([
      for this in var.ipv6_super_intra_vpc_security_group_rules.peer.ipv6_intra_vpc_security_group_rules : this.account_id
    ])) <= 1
    error_message = "All peer Intra VPC Security Group Rules must have the same account id as each other and the aws.peer provider alias for Super Intra VPC Security Group Rules."
  }

  validation {
    condition     = alltrue([for this in var.ipv6_super_intra_vpc_security_group_rules.peer.ipv6_intra_vpc_security_group_rules : length(this.vpcs) > 1])
    error_message = "There must be at least 2 peer VPCs per peer Intra VPC Security Group Rule."
  }

  # cross region rules check
  validation {
    condition = [
      for this in var.ipv6_super_intra_vpc_security_group_rules.local.ipv6_intra_vpc_security_group_rules : this.rule
      ] == [
      for this in var.ipv6_super_intra_vpc_security_group_rules.peer.ipv6_intra_vpc_security_group_rules : this.rule
    ]
    error_message = "The local Intra VPC Security Group Rules must have the same set of rules as the peer Intra VPC Security Group Rules for Super Intra VPC Security Group Rules."
  }
}

