variable "env_prefix" {
  description = "prod, stage, test"
  type        = string
}

variable "full_mesh_trio" {
  description = "full mesh trio configuration"
  type = object({
    one = object({
      centralized_router = object({
        account_id      = string
        amazon_side_asn = string
        full_name       = string
        id              = string
        name            = string
        region          = string
        route_table_id  = string
        vpcs = map(object({
          network_cidr            = string
          secondary_cidrs         = optional(list(string), [])
          ipv6_network_cidr       = optional(string)
          ipv6_secondary_cidrs    = optional(list(string), [])
          private_route_table_ids = list(string)
          public_route_table_ids  = list(string)
        }))
      })
    })
    two = object({
      centralized_router = object({
        account_id      = string
        amazon_side_asn = string
        full_name       = string
        id              = string
        name            = string
        region          = string
        route_table_id  = string
        vpcs = map(object({
          network_cidr            = string
          secondary_cidrs         = optional(list(string), [])
          ipv6_network_cidr       = optional(string)
          ipv6_secondary_cidrs    = optional(list(string), [])
          private_route_table_ids = list(string)
          public_route_table_ids  = list(string)
        }))
      })
    })
    three = object({
      centralized_router = object({
        account_id      = string
        amazon_side_asn = string
        full_name       = string
        id              = string
        name            = string
        region          = string
        route_table_id  = string
        vpcs = map(object({
          network_cidr            = string
          secondary_cidrs         = optional(list(string), [])
          ipv6_network_cidr       = optional(string)
          ipv6_secondary_cidrs    = optional(list(string), [])
          private_route_table_ids = list(string)
          public_route_table_ids  = list(string)
        }))
      })
    })
  })

  validation {
    condition = length(
      distinct([var.full_mesh_trio.one.centralized_router.name, var.full_mesh_trio.two.centralized_router.name, var.full_mesh_trio.three.centralized_router.name])
    ) == length([var.full_mesh_trio.one.centralized_router.name, var.full_mesh_trio.two.centralized_router.name, var.full_mesh_trio.three.centralized_router.name])
    error_message = "All Centralized Routers must have a unique names across regions."
  }

  validation {
    condition = length(
      distinct([var.full_mesh_trio.one.centralized_router.amazon_side_asn, var.full_mesh_trio.two.centralized_router.amazon_side_asn, var.full_mesh_trio.three.centralized_router.amazon_side_asn])
    ) == length([var.full_mesh_trio.one.centralized_router.amazon_side_asn, var.full_mesh_trio.two.centralized_router.amazon_side_asn, var.full_mesh_trio.three.centralized_router.amazon_side_asn])
    error_message = "All Centralized Routers must have a unique amazon side ASN number across regions."
  }

  validation {
    condition     = length(distinct([var.full_mesh_trio.one.centralized_router.account_id, var.full_mesh_trio.two.centralized_router.account_id, var.full_mesh_trio.three.centralized_router.account_id])) <= 1
    error_message = "All Centralized Routers must have the same account id as each other, no cross account at this time."
  }

  validation {
    condition = length(
      distinct(concat(keys(var.full_mesh_trio.one.centralized_router.vpcs), keys(var.full_mesh_trio.two.centralized_router.vpcs), keys(var.full_mesh_trio.three.centralized_router.vpcs)))
    ) == length(concat(keys(var.full_mesh_trio.one.centralized_router.vpcs), keys(var.full_mesh_trio.two.centralized_router.vpcs), keys(var.full_mesh_trio.three.centralized_router.vpcs)))
    error_message = "All VPC names must be unique across regions."
  }

  validation {
    condition = length(
      distinct(concat([for vpc in var.full_mesh_trio.one.centralized_router.vpcs : vpc.network_cidr], [for vpc in var.full_mesh_trio.two.centralized_router.vpcs : vpc.network_cidr], [for vpc in var.full_mesh_trio.three.centralized_router.vpcs : vpc.network_cidr]))
    ) == length(concat([for vpc in var.full_mesh_trio.one.centralized_router.vpcs : vpc.network_cidr], [for vpc in var.full_mesh_trio.two.centralized_router.vpcs : vpc.network_cidr], [for vpc in var.full_mesh_trio.three.centralized_router.vpcs : vpc.network_cidr]))
    error_message = "All VPC network CIDRs must be unique across regions."
  }

  validation {
    condition = length(
      distinct(concat(flatten([for vpc in var.full_mesh_trio.one.centralized_router.vpcs : vpc.secondary_cidrs]), flatten([for vpc in var.full_mesh_trio.two.centralized_router.vpcs : vpc.secondary_cidrs]), flatten([for vpc in var.full_mesh_trio.three.centralized_router.vpcs : vpc.secondary_cidrs])))
    ) == length(concat(flatten([for vpc in var.full_mesh_trio.one.centralized_router.vpcs : vpc.secondary_cidrs]), flatten([for vpc in var.full_mesh_trio.two.centralized_router.vpcs : vpc.secondary_cidrs]), flatten([for vpc in var.full_mesh_trio.three.centralized_router.vpcs : vpc.secondary_cidrs])))
    error_message = "All VPC secondary CIDRs must be unique across regions."
  }

  validation {
    condition = length(compact([for vpc in var.full_mesh_trio.one.centralized_router.vpcs : vpc.ipv6_network_cidr])) > 0 ? length(
      distinct(concat(compact([for vpc in var.full_mesh_trio.one.centralized_router.vpcs : vpc.ipv6_network_cidr]), compact([for vpc in var.full_mesh_trio.two.centralized_router.vpcs : vpc.ipv6_network_cidr]), compact([for vpc in var.full_mesh_trio.three.centralized_router.vpcs : vpc.ipv6_network_cidr])))
    ) == length(concat(compact([for vpc in var.full_mesh_trio.one.centralized_router.vpcs : vpc.ipv6_network_cidr]), compact([for vpc in var.full_mesh_trio.two.centralized_router.vpcs : vpc.ipv6_network_cidr]), compact([for vpc in var.full_mesh_trio.three.centralized_router.vpcs : vpc.ipv6_network_cidr]))) : true
    error_message = "All VPC IPv6 network CIDRs must be unique across regions."
  }

  validation {
    condition = length(
      distinct(concat(flatten([for vpc in var.full_mesh_trio.one.centralized_router.vpcs : vpc.ipv6_secondary_cidrs]), flatten([for vpc in var.full_mesh_trio.two.centralized_router.vpcs : vpc.ipv6_secondary_cidrs]), flatten([for vpc in var.full_mesh_trio.three.centralized_router.vpcs : vpc.ipv6_secondary_cidrs])))
    ) == length(concat(flatten([for vpc in var.full_mesh_trio.one.centralized_router.vpcs : vpc.ipv6_secondary_cidrs]), flatten([for vpc in var.full_mesh_trio.two.centralized_router.vpcs : vpc.ipv6_secondary_cidrs]), flatten([for vpc in var.full_mesh_trio.three.centralized_router.vpcs : vpc.ipv6_secondary_cidrs])))
    error_message = "All VPC IPv6 secondary CIDRs must be unique across regions."
  }
}

variable "policy" {
  description = "cross-region routing policy constraints"
  type = object({
    default = optional(string, "allow")
    deny = optional(list(object({
      from_vpc = object({
        network_cidr    = string
        secondary_cidrs = optional(list(string), [])
      })
      to_vpc = object({
        network_cidr    = string
        secondary_cidrs = optional(list(string), [])
      })
    })), [])
    allow = optional(list(object({
      from_vpc = object({
        network_cidr    = string
        secondary_cidrs = optional(list(string), [])
      })
      to_vpc = object({
        network_cidr    = string
        secondary_cidrs = optional(list(string), [])
      })
    })), [])
    segments = optional(map(list(object({
      network_cidr    = string
      secondary_cidrs = optional(list(string), [])
    }))), {})
  })
  default = {}

  validation {
    condition     = contains(["allow", "deny"], var.policy.default)
    error_message = "Policy default must be \"allow\" or \"deny\"."
  }
}

variable "tags" {
  description = "Additional Tags"
  type        = map(string)
  default     = {}
}
