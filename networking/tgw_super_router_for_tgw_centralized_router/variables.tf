variable "env_prefix" {
  description = "prod, stage, test"
  type        = string
}

variable "region_az_labels" {
  description = "Region and AZ names mapped to short naming conventions for labeling"
  type        = map(string)
}

variable "super_router" {
  description = "Super Router config"
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
        vpcs = map(object({
          network_cidr                 = string
          az_to_public_route_table_id  = map(string)
          az_to_private_route_table_id = map(string)
        }))
      })), {})
    })
  })

  validation {
    condition = length(
      distinct([for this in var.super_router.local.centralized_routers : this.amazon_side_asn])
    ) == length([for this in var.super_router.local.centralized_routers : this.amazon_side_asn])
    error_message = "All local centralized routers must have a unique amazon_side_asn number."
  }

  validation {
    condition     = length(distinct([for this in var.super_router.local.centralized_routers : this.region])) < 2
    error_message = "All local centralized routers must have the same region as each other and the aws.local provider alias."
  }

  validation {
    condition     = length(distinct([for this in var.super_router.local.centralized_routers : this.account_id])) < 2
    error_message = "All local centralized routers must have the same account id as each other and the aws.local provider alias."
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
}

variable "tags" {
  description = "Additional Tags"
  type        = map(string)
  default     = {}
}
