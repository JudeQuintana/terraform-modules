variable "env_prefix" {
  description = "prod, stage, test"
  type        = string
}

variable "region_az_labels" {
  description = "Region and AZ names mapped to short naming conventions for labeling"
  type        = map(string)
}

variable "full_mesh_intra_vpc_security_group_rules" {
  description = "full mesh intra vpc security group rules configuration"
  type = object({
    # security rule object to allow inbound across vpcs intra-vpc security group
    one = object({
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
    two = object({
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
    three = object({
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
}

