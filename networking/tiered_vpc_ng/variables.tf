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
    name = string
    # ipv4 requires ipam
    ipv4 = object({
      network_cidr    = string
      secondary_cidrs = optional(list(string), [])
      ipam_pool = object({
        id = string
      })
    })
    # ipv6 requires ipam
    ipv6 = optional(object({
      network_cidr = optional(string)
      ipam_pool = optional(object({
        id = optional(string)
      }), {})
    }), {})
    azs = map(object({
      eigw = optional(bool, false)
      private_subnets = optional(list(object({
        name      = string
        cidr      = string
        ipv6_cidr = optional(string)
        special   = optional(bool, false)
      })), [])
      public_subnets = optional(list(object({
        name      = string
        cidr      = string
        ipv6_cidr = optional(string)
        special   = optional(bool, false)
        natgw     = optional(bool, false)
      })), [])
    }))
    enable_dns_support   = optional(bool, true)
    enable_dns_hostnames = optional(bool, true)
  })

  # using ipv4 validation via cidrnetmask function instead of regex for ipv4
  validation {
    condition     = can(cidrnetmask(var.tiered_vpc.ipv4.network_cidr))
    error_message = "The VPC network CIDR must be in valid IPv4 CIDR notation (ie x.x.x.x/xx -> 10.46.0.0/20). Check for typos."
  }

  validation {
    condition = alltrue(flatten([
      for this in var.tiered_vpc.azs : [
        for subnet_cidr in concat(this.private_subnets[*].cidr, this.public_subnets[*].cidr) :
        can(cidrnetmask(subnet_cidr))
    ]]))
    error_message = "The VPC private and public subnet CDIRs must be in valid IPv4 CIDR notation (ie x.x.x.x/xx -> 10.46.0.0/20). Check for typos."
  }

  validation {
    condition = alltrue(flatten([
      for this in var.tiered_vpc.azs : [
        for subnet_cidr in var.tiered_vpc.ipv4.secondary_cidrs :
        can(cidrnetmask(subnet_cidr))
      ]
    ]))
    error_message = "Each Secondary VPC CIDR must have valid IPv4 CIDR notation (ie x.x.x.x/xx -> 10.46.0.0/20). Check for typos."
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
    condition = alltrue([
      for this in var.tiered_vpc.azs :
      anytrue([for ipv6_cidr in compact(concat(this.private_subnets[*].ipv6_cidr, this.public_subnets[*].ipv6_cidr)) : true]) ? var.tiered_vpc.ipv6.network_cidr != null : true
    ])
    error_message = "The var.tiered_vpc.ipv6.network_cidr must be assigned to the VPC if a private subnet or public subnet with an IPv6 CIDR is configured in a dual stack configuration."
  }

  validation {
    condition = var.tiered_vpc.ipv6.network_cidr != null ? alltrue([
      for this in var.tiered_vpc.azs :
    length(compact(this.private_subnets[*].ipv6_cidr)) == length(this.private_subnets[*].cidr) && length(compact(this.public_subnets[*].ipv6_cidr)) == length(this.public_subnets[*].cidr)]) : true
    error_message = "If var.tiered_vpc.ipv6.network_cidr is configured for the VPC then all private subnets and/or public subnets that are set must also be configured with a IPv6 CIDR in a dual stack configuration."
  }

  validation {
    condition = alltrue([
      for this in var.tiered_vpc.azs :
      this.eigw ? length([for subnet in this.private_subnets : subnet.ipv6_cidr if subnet.ipv6_cidr != null]) > 0 : true
    ])
    error_message = "If eigw is true for an AZ then at least one private IPv6 dual stack subnet must be configured in the same AZ."
  }

  validation {
    condition     = var.tiered_vpc.ipv6.network_cidr != null ? var.tiered_vpc.ipv6.ipam_pool.id != null : true
    error_message = "If var.tiered_vpc.ipv6.network_cidr is defined, then var.tiered_vpc.ipv6.ipam_pool.id must be defined."
  }

  validation {
    condition     = var.tiered_vpc.ipv6.ipam_pool.id != null ? var.tiered_vpc.ipv6.network_cidr != null : true
    error_message = "If var.tiered_vpc.ipv6.ipam_pool.id is defined, then var.tiered_vpc.ipv6.network_cidr must be defined."
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

  validation {
    condition = length(distinct(flatten([
      for this in var.tiered_vpc.azs : compact(concat(this.private_subnets[*].ipv6_cidr, this.public_subnets[*].ipv6_cidr))
      ]))) == length(flatten([
      for this in var.tiered_vpc.azs : compact(concat(this.private_subnets[*].ipv6_cidr, this.public_subnets[*].ipv6_cidr))
    ]))
    error_message = "Each subnet IPv6 CDIR must be unique across all AZs."
  }
}

variable "tags" {
  description = "Additional Tags"
  type        = map(string)
  default     = {}
}
