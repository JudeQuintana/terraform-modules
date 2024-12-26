variable "env_prefix" {
  description = "prod, stage, test"
  type        = string
}

variable "region_az_labels" {
  description = "Region and AZ names mapped to short naming conventions for labeling"
  type        = map(string)
}

variable "centralized_router" {
  description = "Centralized Router configuration"
  type = object({
    name             = string
    amazon_side_asn  = number
    propagate_routes = optional(bool, false)
    blackhole = optional(object({
      cidrs      = optional(list(string), [])
      ipv6_cidrs = optional(list(string), [])
    }), {})
    vpcs = optional(map(object({
      account_id                 = string
      region                     = string
      full_name                  = string
      id                         = string
      name                       = string
      network_cidr               = string
      secondary_cidrs            = optional(list(string), [])
      ipv6_network_cidr          = optional(string)
      ipv6_secondary_cidrs       = optional(list(string), [])
      private_route_table_ids    = list(string)
      public_route_table_ids     = list(string)
      private_special_subnet_ids = list(string)
      public_special_subnet_ids  = list(string)
      public_natgw_az_to_eip     = map(string)
      centralized_egress_private = bool
      centralized_egress_central = bool
    })), {})
  })

  validation {
    condition     = alltrue([for this in var.centralized_router.blackhole.cidrs : can(cidrnetmask(this))])
    error_message = "The blackhole network CIDRs must be in valid IPv4 CIDR notation (ie x.x.x.x/xx -> 10.46.0.0/20). Check for typos."
  }

  validation {
    condition = length(distinct([
      for this in var.centralized_router.vpcs : this.name
      ])) == length([
      for this in var.centralized_router.vpcs : this.name
    ])
    error_message = "All VPCs must have unique names."
  }

  validation {
    condition = length(distinct([
      for this in var.centralized_router.vpcs : this.network_cidr
      ])) == length([
      for this in var.centralized_router.vpcs : this.network_cidr
    ])
    error_message = "All VPCs must have unique IPv4 network CIDRs."
  }

  validation {
    condition = length(distinct(flatten([
      for this in var.centralized_router.vpcs : this.secondary_cidrs
      ]))) == length(flatten([
      for this in var.centralized_router.vpcs : this.secondary_cidrs
    ]))
    error_message = "All VPCs must have unique IPv4 secondary CIDRs."
  }

  validation {
    condition = length(distinct(compact([
      for this in var.centralized_router.vpcs : this.ipv6_network_cidr
      ]))) == length(compact([
      for this in var.centralized_router.vpcs : this.ipv6_network_cidr
    ]))
    error_message = "All VPCs must have unique IPv6 network CIDRs."
  }

  validation {
    condition = length(distinct(flatten([
      for this in var.centralized_router.vpcs : this.ipv6_secondary_cidrs
      ]))) == length(flatten([
      for this in var.centralized_router.vpcs : this.ipv6_secondary_cidrs
    ]))
    error_message = "All VPCs must have unique IPv6 secondary CIDRs."
  }

  validation {
    condition = (
      var.centralized_router.amazon_side_asn >= 64512 && var.centralized_router.amazon_side_asn <= 65534
      ) || (
      var.centralized_router.amazon_side_asn >= 4200000000 && var.centralized_router.amazon_side_asn <= 4294967294
    )
    error_message = "The amazon side ASN should be within 64512 to 65534 (inclusive) for 16-bit ASNs and 4200000000 to 4294967294 (inclusive) for 32-bit ASNs."
  }

  validation {
    condition = anytrue([
      for this in var.centralized_router.vpcs : this.centralized_egress_private
    ]) ? alltrue([for this in var.centralized_router.vpcs : length(this.public_natgw_az_to_eip) == 0 if this.centralized_egress_private]) : true
    error_message = "Every VPC with centralized_egress_private = true must have 0 NATGWs per AZ."
  }

  validation {
    condition = anytrue([
      for this in var.centralized_router.vpcs : this.centralized_egress_central
    ]) ? length([for this in var.centralized_router.vpcs : this.centralized_egress_central if this.centralized_egress_central]) == 1 : true
    error_message = "There must be 1 VPC with centralized_egress_central = true."
  }
}

variable "tags" {
  description = "Additional Tags"
  type        = map(string)
  default     = {}
}
