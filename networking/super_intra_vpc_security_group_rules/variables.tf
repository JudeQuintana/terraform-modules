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
    local = map(object({
      rule = object({
        label      = string
        protocol   = string
        from_port  = number
        to_port    = number
        account_id = string
        region     = string
      })
      vpcs = map(object({
        id                          = string
        intra_vpc_security_group_id = string
        network_cidr                = string
        account_id                  = string
        region                      = string
      }))
    }))
    peer = map(object({
      rule = object({
        label      = string
        protocol   = string
        from_port  = number
        to_port    = number
        account_id = string
        region     = string
      })
      vpcs = map(object({
        id                          = string
        intra_vpc_security_group_id = string
        network_cidr                = string
        account_id                  = string
        region                      = string
      }))
    }))
  })

  #validations for labels, protocol, regions, account_id
}
