variable "env_prefix" {
  description = "prod, stage, test"
  type        = string
}

variable "region_az_labels" {
  description = "Region and AZ names mapped to short naming conventions for labeling"
  type        = map(string)
}

variable "super_router" {
  description = "Super Router configuration"
  type = object({
    name = string
    local = object({
      amazon_side_asn = number
      blackhole = optional(object({
        cidrs      = optional(list(string), [])
        ipv6_cidrs = optional(list(string), [])
      }), {})
      centralized_routers = optional(map(object({
        account_id      = string
        amazon_side_asn = string
        full_name       = string
        id              = string
        name            = string
        region          = string
        route_table_id  = string
        vpcs = optional(map(object({
          id                      = string
          name                    = string
          full_name               = string
          network_cidr            = string
          secondary_cidrs         = list(string)
          ipv6_network_cidr       = string
          ipv6_secondary_cidrs    = list(string)
          private_route_table_ids = list(string)
          public_route_table_ids  = list(string)
        })), {})
      })), {})
    })
    peer = object({
      amazon_side_asn = number
      blackhole = optional(object({
        cidrs      = optional(list(string), [])
        ipv6_cidrs = optional(list(string), [])
      }), {})
      centralized_routers = optional(map(object({
        account_id      = string
        amazon_side_asn = string
        full_name       = string
        id              = string
        name            = string
        region          = string
        route_table_id  = string
        vpcs = optional(map(object({
          id                      = string
          name                    = string
          full_name               = string
          network_cidr            = string
          secondary_cidrs         = list(string)
          ipv6_network_cidr       = string
          ipv6_secondary_cidrs    = list(string)
          private_route_table_ids = list(string)
          public_route_table_ids  = list(string)
        })), {})
      })), {})
    })
  })

  validation {
    condition = length(
      distinct([for this in var.super_router.local.centralized_routers : this.name])
    ) == length([for this in var.super_router.local.centralized_routers : this.name])
    error_message = "All local Centralized Routers must have a unique names."
  }

  validation {
    condition = length(
      distinct([for this in var.super_router.local.centralized_routers : this.amazon_side_asn])
    ) == length([for this in var.super_router.local.centralized_routers : this.amazon_side_asn])
    error_message = "All local Centralized Routers must have a unique amazon side ASN number."
  }

  validation {
    condition     = length(distinct([for this in var.super_router.local.centralized_routers : this.region])) <= 1
    error_message = "All local Centralized Routers must have the same region as each other and the aws.local provider alias for Super Router."
  }

  validation {
    condition     = length(distinct([for this in var.super_router.local.centralized_routers : this.account_id])) <= 1
    error_message = "All local Centralized Routers must have the same account id as each other and the aws.local provider alias for Super Router."
  }

  validation {
    condition = (
      var.super_router.local.amazon_side_asn >= 64512 && var.super_router.local.amazon_side_asn <= 65534
      ) || (
      var.super_router.local.amazon_side_asn >= 4200000000 && var.super_router.local.amazon_side_asn <= 4294967294
    )
    error_message = "The local Super Router amazon side ASNs should be within 64512 to 65534 (inclusive) for 16-bit ASNs and 4200000000 to 4294967294 (inclusive) for 32-bit ASNs."
  }

  validation {
    condition = length(
      distinct([for this in var.super_router.peer.centralized_routers : this.name])
    ) == length([for this in var.super_router.peer.centralized_routers : this.name])
    error_message = "All peer Centralized Routers must have a unique names."
  }

  validation {
    condition = length(
      distinct([for this in var.super_router.peer.centralized_routers : this.amazon_side_asn])
    ) == length([for this in var.super_router.peer.centralized_routers : this.amazon_side_asn])
    error_message = "All peer Centralized Routers must have a unique amazon side ASN number."
  }

  validation {
    condition     = length(distinct([for this in var.super_router.peer.centralized_routers : this.region])) <= 1
    error_message = "All peer Centralized Routers must have the same region as each other and the aws.peer provider alias for Super Router."
  }

  validation {
    condition     = length(distinct([for this in var.super_router.peer.centralized_routers : this.account_id])) <= 1
    error_message = "All peer Centralized Routers must have the same account id as each other and the aws.peer provider alias for Super Router."
  }

  validation {
    condition = (
      var.super_router.peer.amazon_side_asn >= 64512 && var.super_router.peer.amazon_side_asn <= 65534
      ) || (
      var.super_router.peer.amazon_side_asn >= 4200000000 && var.super_router.peer.amazon_side_asn <= 4294967294
    )
    error_message = "The peer Super Router amazon side ASNs should be within 64512 to 65534 (inclusive) for 16-bit ASNs and 4200000000 to 4294967294 (inclusive) for 32-bit ASNs."
  }

  # cross region checks
  validation {
    condition = length(
      distinct(concat(flatten([for this in var.super_router.local.centralized_routers : [for vpc in this.vpcs : vpc.name]]), flatten([for this in var.super_router.peer.centralized_routers : [for vpc in this.vpcs : vpc.name]])))
    ) == length(concat(flatten([for this in var.super_router.local.centralized_routers : [for vpc in this.vpcs : vpc.name]]), flatten([for this in var.super_router.peer.centralized_routers : [for vpc in this.vpcs : vpc.name]])))
    error_message = "All VPC names must be unique across regions."
  }

  validation {
    condition = length(
      distinct(concat(flatten([for this in var.super_router.local.centralized_routers : flatten([for vpc in this.vpcs : concat([vpc.network_cidr], vpc.secondary_cidrs)])]), flatten([for this in var.super_router.peer.centralized_routers : flatten([for vpc in this.vpcs : concat([vpc.network_cidr], vpc.secondary_cidrs)])])))
    ) == length(concat(flatten([for this in var.super_router.local.centralized_routers : flatten([for vpc in this.vpcs : concat([vpc.network_cidr], vpc.secondary_cidrs)])]), flatten([for this in var.super_router.peer.centralized_routers : flatten([for vpc in this.vpcs : concat([vpc.network_cidr], vpc.secondary_cidrs)])])))
    error_message = "All VPC IPv4 network and secondary CIDRs must be unique across regions."
  }

  validation {
    condition = length(
      distinct(concat(flatten([for this in var.super_router.local.centralized_routers : flatten([for vpc in this.vpcs : concat(compact([vpc.ipv6_network_cidr]), vpc.ipv6_secondary_cidrs)])]), flatten([for this in var.super_router.peer.centralized_routers : flatten([for vpc in this.vpcs : concat(compact([vpc.ipv6_network_cidr]), vpc.ipv6_secondary_cidrs)])])))
    ) == length(concat(flatten([for this in var.super_router.local.centralized_routers : flatten([for vpc in this.vpcs : concat(compact([vpc.ipv6_network_cidr]), vpc.ipv6_secondary_cidrs)])]), flatten([for this in var.super_router.peer.centralized_routers : flatten([for vpc in this.vpcs : concat(compact([vpc.ipv6_network_cidr]), vpc.ipv6_secondary_cidrs)])])))
    error_message = "All VPC IPv6 network and secondary CIDRs must be unique across regions."
  }

  validation {
    condition = length(
      distinct(concat([for this in var.super_router.local.centralized_routers : this.name], [for this in var.super_router.peer.centralized_routers : this.name]))
    ) == length(concat([for this in var.super_router.local.centralized_routers : this.name], [for this in var.super_router.peer.centralized_routers : this.name]))
    error_message = "All Centralized Router names must be unique across regions."
  }

  validation {
    condition = length(
      distinct(concat([for this in var.super_router.local.centralized_routers : this.amazon_side_asn], [var.super_router.local.amazon_side_asn], [for this in var.super_router.peer.centralized_routers : this.amazon_side_asn], [var.super_router.peer.amazon_side_asn]))
    ) == length(concat([for this in var.super_router.local.centralized_routers : this.amazon_side_asn], [var.super_router.local.amazon_side_asn], [for this in var.super_router.peer.centralized_routers : this.amazon_side_asn], [var.super_router.peer.amazon_side_asn]))
    error_message = "All Centralized Routers and Super Router amazon side ASNs must be unique across regions."
  }
}

variable "routing_policy" {
  description = "Routing policy for cross-region and intra-region VPC routes"
  type = object({
    default = optional(string, "allow")
    deny = optional(list(object({
      from = object({
        network_cidr         = string
        secondary_cidrs      = optional(list(string), [])
        ipv6_network_cidr    = optional(string)
        ipv6_secondary_cidrs = optional(list(string), [])
      })
      to = object({
        network_cidr         = string
        secondary_cidrs      = optional(list(string), [])
        ipv6_network_cidr    = optional(string)
        ipv6_secondary_cidrs = optional(list(string), [])
      })
    })), [])
    allow = optional(list(object({
      from = object({
        network_cidr         = string
        secondary_cidrs      = optional(list(string), [])
        ipv6_network_cidr    = optional(string)
        ipv6_secondary_cidrs = optional(list(string), [])
      })
      to = object({
        network_cidr         = string
        secondary_cidrs      = optional(list(string), [])
        ipv6_network_cidr    = optional(string)
        ipv6_secondary_cidrs = optional(list(string), [])
      })
    })), [])
    segments = optional(map(list(object({
      network_cidr         = string
      secondary_cidrs      = optional(list(string), [])
      ipv6_network_cidr    = optional(string)
      ipv6_secondary_cidrs = optional(list(string), [])
    }))), {})
  })
  default = {}

  validation {
    condition     = contains(["allow", "deny"], var.routing_policy.default)
    error_message = "Policy default must be \"allow\" or \"deny\"."
  }

  validation {
    condition = length(
      distinct(flatten([for vpcs in var.routing_policy.segments : [for vpc in vpcs : vpc.network_cidr]]))
    ) == length(flatten([for vpcs in var.routing_policy.segments : [for vpc in vpcs : vpc.network_cidr]]))
    error_message = "A VPC cannot belong to multiple segments. Each VPC (network_cidr) must appear in only one segment or use allow = [] to create explicit allows across segments."
  }
}

variable "tags" {
  description = "Additional Tags"
  type        = map(string)
  default     = {}
}
