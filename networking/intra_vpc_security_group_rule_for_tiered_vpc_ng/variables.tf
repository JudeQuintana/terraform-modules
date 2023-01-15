variable "env_prefix" {
  description = "prod, stage, test"
  type        = string
}

variable "region_az_labels" {
  description = "Region and AZ names mapped to short naming conventions for labeling"
  type        = map(string)
}

variable "intra_vpc_access" {
  description = "intra vpc access configuration"
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
      network_cidr                = string
      region                      = string
    }))
  })

  validation {
    condition = length(distinct([
      for this in var.intra_vpc_access.vpcs : this.network_cidr
      ])) == length([
      for this in var.intra_vpc_access.vpcs : this.network_cidr
    ])
    error_message = "All VPCs must have unique network CIDRs."
  }

  validation {
    condition     = length(var.intra_vpc_access.vpcs) > 1
    error_message = "There must be at least 2 VPCs."
  }
}

