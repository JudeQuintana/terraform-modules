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
      account_id = string
      region     = string
      vpc_id_to_rule = map(object({
        label                       = string
        protocol                    = string
        from_port                   = number
        to_port                     = number
        intra_vpc_security_group_id = string
        network_cidrs               = list(string)
        type                        = string
        #vpc_id                      = string
      }))
      vpcs = map(object({
        id           = string
        network_cidr = string
        region       = string
      }))
    })
    peer = object({
      account_id = string
      region     = string
      vpc_id_to_rule = map(object({
        label                       = string
        protocol                    = string
        from_port                   = number
        to_port                     = number
        intra_vpc_security_group_id = string
        network_cidrs               = list(string)
        type                        = string
        #vpc_id                      = string
      }))
      vpcs = map(object({
        id           = string
        network_cidr = string
        region       = string
      }))
    })

  })

  #validations for labels, protocol
}
