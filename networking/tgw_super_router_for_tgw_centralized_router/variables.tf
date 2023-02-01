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
    name            = string
    blackhole_cidrs = optional(list(string), [])
    local = object({
      amazon_side_asn = number
      centralized_routers = optional(map(object({
        account_id      = string
        amazon_side_asn = string
        full_name       = string
        id              = string
        name            = string
        region          = string
        route_table_id  = string
        vpc = object({
          names         = list(string)
          network_cidrs = list(string)
          routes = list(object({
            route_table_id         = string
            destination_cidr_block = string
            transit_gateway_id     = string
          }))
        })
      })), {})
    })
    peer = object({
      amazon_side_asn = number
      centralized_routers = optional(map(object({
        account_id      = string
        amazon_side_asn = string
        full_name       = string
        id              = string
        name            = string
        region          = string
        route_table_id  = string
        vpc = object({
          names         = list(string)
          network_cidrs = list(string)
          routes = list(object({
            route_table_id         = string
            destination_cidr_block = string
            transit_gateway_id     = string
          }))
        })
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
      distinct(concat(flatten([for this in var.super_router.local.centralized_routers : this.vpc.names]), flatten([for this in var.super_router.peer.centralized_routers : this.vpc.names])))
    ) == length(concat(flatten([for this in var.super_router.local.centralized_routers : this.vpc.names]), flatten([for this in var.super_router.peer.centralized_routers : this.vpc.names])))
    error_message = "All VPC names must be unique across regions."
  }

  validation {
    condition = length(
      distinct(concat(flatten([for this in var.super_router.local.centralized_routers : this.vpc.network_cidrs]), flatten([for this in var.super_router.peer.centralized_routers : this.vpc.network_cidrs])))
    ) == length(concat(flatten([for this in var.super_router.local.centralized_routers : this.vpc.network_cidrs]), flatten([for this in var.super_router.peer.centralized_routers : this.vpc.network_cidrs])))
    error_message = "All VPC network CIDRs must be unique across regions."
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

variable "tags" {
  description = "Additional Tags"
  type        = map(string)
  default     = {}
}
