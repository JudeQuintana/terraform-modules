variable "env_prefix" {
  description = "prod, stage, test"
  type        = string
}

variable "region_az_labels" {
  description = "Region and AZ names mapped to short naming conventions for labeling"
  type        = map(string)
}

variable "tiered_vpc" {
  description = "Tiered VPC configuration"
  type = object({
    name         = string
    network_cidr = string
    azs = map(object({
      private_subnets = optional(list(object({
        name    = string
        cidr    = string
        special = optional(bool, false)
      })), [])
      public_subnets = optional(list(object({
        name    = string
        cidr    = string
        special = optional(bool, false)
        natgw   = optional(bool, false)
      })), [])
    }))
    enable_dns_support   = optional(bool, true)
    enable_dns_hostnames = optional(bool, true)
  })

  # using ipv4 validation via cidrnetmask function instead of regex until ipv6 is added
  validation {
    condition = can(cidrnetmask(var.tiered_vpc.network_cidr)) && alltrue(flatten([
      for this in var.tiered_vpc.azs : [
        for subnet_cidr in concat(this.private_subnets[*].cidr, this.public_subnets[*].cidr) :
        can(cidrnetmask(subnet_cidr))
      ]
    ]))
    error_message = "The VPC network CIDR and subnet CDIRs must be in valid IPv4 CIDR notation (ie x.x.x.x/xx -> 10.46.0.0/20). Check for typos."
  }

  validation {
    condition     = alltrue([for this in keys(var.tiered_vpc.azs) : contains(["a", "b", "c", "d", "e", "f"], this)])
    error_message = "The AZ key should be a single character for the AZ. a,b,c,d,e or f."
  }

  validation {
    condition = alltrue([
      for this in var.tiered_vpc.azs :
      length([for subnet in concat(this.private_subnets, this.public_subnets) : subnet.special if subnet.special]) == 1
    ])
    error_message = "There must be either 1 private subnet or 1 public subnet with the special attribute set to true per AZ."
  }

  validation {
    condition = alltrue([
      for this in var.tiered_vpc.azs :
      anytrue(this.public_subnets[*].natgw) ? length([for subnet in this.public_subnets : subnet.natgw if subnet.natgw]) == 1 : true
    ])
    error_message = "There can be only be 1 public subnet with a NATGW enabled per AZ."
  }

  validation {
    condition = alltrue([
      for this in var.tiered_vpc.azs :
      anytrue(this.public_subnets[*].natgw) ? length(this.private_subnets) > 0 : true
    ])
    error_message = "At least 1 private subnet must exist if a NATGW is enabled for a public subnet in the same AZ."
  }

  validation {
    condition = length(distinct(flatten([
      for this in var.tiered_vpc.azs : concat(this.private_subnets[*].name, this.public_subnets[*].name)
      ]))) == length(flatten([
      for this in var.tiered_vpc.azs : concat(this.private_subnets[*].name, this.public_subnets[*].name)
    ]))
    error_message = "Each subnet name must be unique across all AZs."
  }

  validation {
    condition = length(distinct(flatten([
      for this in var.tiered_vpc.azs : concat(this.private_subnets[*].cidr, this.public_subnets[*].cidr)
      ]))) == length(flatten([
      for this in var.tiered_vpc.azs : concat(this.private_subnets[*].cidr, this.public_subnets[*].cidr)
    ]))
    error_message = "Each subnet CDIR must be unique across all AZs."
  }
}

variable "tags" {
  description = "Additional Tags"
  type        = map(string)
  default     = {}
}
