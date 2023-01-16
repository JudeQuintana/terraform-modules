variable "env_prefix" {
  description = "prod, stage, test"
  type        = string
}

variable "region_az_labels" {
  description = "Region and AZ names mapped to short naming conventions for labeling"
  type        = map(string)
}

variable "super_intra_vpc_access" {
  description = "super intra vpc access configuration"
  type = object({
    # security rule object to allow inbound across vpcs intra-vpc security group
    local = object({
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
        network_cidr                = string
        region                      = string
      }))
    })
    peer = object({
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
        network_cidr                = string
        region                      = string
      }))
    })
  })
}
