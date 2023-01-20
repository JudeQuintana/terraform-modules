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
        account_id        = string
        amazon_side_asn   = string
        full_name         = string
        id                = string
        region            = string
        route_table_id    = string
        vpc_network_cidrs = list(string)
        vpc_routes = list(object({
          route_table_id         = string
          destination_cidr_block = string
          transit_gateway_id     = string
        }))
        vpcs = map(object({
          network_cidr                 = string
          az_to_public_route_table_id  = map(string)
          az_to_private_route_table_id = map(string)
        }))
      })), {})
    })
    peer = object({
      amazon_side_asn = number
      centralized_routers = optional(map(object({
        account_id        = string
        amazon_side_asn   = string
        full_name         = string
        id                = string
        region            = string
        route_table_id    = string
        vpc_network_cidrs = list(string)
        vpc_routes = list(object({
          route_table_id         = string
          destination_cidr_block = string
          transit_gateway_id     = string
        }))
        vpcs = list(object({
          network_cidr            = string
          private_route_table_ids = list(string)
          public_route_table_ids  = list(string)
        }))
      })), [])
    })
  })

  validation {
    condition = length(
      distinct([for this in var.super_router.local.centralized_routers : this.amazon_side_asn])
    ) == length([for this in var.super_router.local.centralized_routers : this.amazon_side_asn])
    error_message = "All local centralized routers must have a unique amazon_side_asn number."
  }

  validation {
    condition     = length(distinct([for this in var.super_router.local.centralized_routers : this.region])) <= 1
    error_message = "All local centralized routers must have the same region as each other and the aws.local provider alias."
  }

  validation {
    condition     = length(distinct([for this in var.super_router.local.centralized_routers : this.account_id])) <= 1
    error_message = "All local centralized routers must have the same account id as each other and the aws.local provider alias."
  }

  validation {
    condition = (
      var.super_router.local.amazon_side_asn >= 64512 && var.super_router.local.amazon_side_asn <= 65534
      ) || (
      var.super_router.local.amazon_side_asn >= 4200000000 && var.super_router.local.amazon_side_asn <= 4294967294
    )
    error_message = "The local super router amazon_side_asn should be within 64512 to 65534 (inclusive) for 16-bit ASNs and 4200000000 to 4294967294 (inclusive) for 32-bit ASNs."
  }

  validation {
    condition = length(
      distinct([for this in var.super_router.peer.centralized_routers : this.amazon_side_asn])
    ) == length([for this in var.super_router.peer.centralized_routers : this.amazon_side_asn])
    error_message = "All peer centralized routers must have a unique amazon_side_asn number."
  }

  validation {
    condition     = length(distinct([for this in var.super_router.peer.centralized_routers : this.region])) < 2
    error_message = "All peer centralized routers must have the same region as each other and the aws.peer provider alias."
  }

  validation {
    condition     = length(distinct([for this in var.super_router.peer.centralized_routers : this.account_id])) < 2
    error_message = "All peer centralized couters must have the same account id as each other and the aws.peer provider alias."
  }

  validation {
    condition = (
      var.super_router.peer.amazon_side_asn >= 64512 && var.super_router.peer.amazon_side_asn <= 65534
      ) || (
      var.super_router.peer.amazon_side_asn >= 4200000000 && var.super_router.peer.amazon_side_asn <= 4294967294
    )
    error_message = "The peer super router amazon_side_asn should be within 64512 to 65534 (inclusive) for 16-bit ASNs and 4200000000 to 4294967294 (inclusive) for 32-bit ASNs."
  }

  validation {
    condition = length(
      distinct(concat(flatten([for this in var.super_router.local.centralized_routers : this.vpc_network_cidrs]), flatten([for this in var.super_router.peer.centralized_routers : this.vpc_network_cidrs])))
    ) == length(concat(flatten([for this in var.super_router.local.centralized_routers : this.vpc_network_cidrs]), flatten([for this in var.super_router.peer.centralized_routers : this.vpc_network_cidrs])))
    error_message = "All VPC network_cidrs must be unique across regions."
  }

  validation {
    condition = length(
      distinct(concat([for this in var.super_router.local.centralized_routers : this.amazon_side_asn], [for this in var.super_router.peer.centralized_routers : this.amazon_side_asn]))
    ) == length(concat([for this in var.super_router.local.centralized_routers : this.amazon_side_asn], [for this in var.super_router.peer.centralized_routers : this.amazon_side_asn]))
    error_message = "All amazon side ASNs must be unique across regions."
  }
}

variable "tags" {
  description = "Additional Tags"
  type        = map(string)
  default     = {}
}
