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
        vpc = object({
          names                   = list(string)
          network_cidrs           = list(string)
          secondary_cidrs         = list(string)
          ipv6_network_cidrs      = list(string)
          ipv6_secondary_cidrs    = list(string)
          private_route_table_ids = list(string)
          public_route_table_ids  = list(string)
        })
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
        vpc = object({
          names                   = list(string)
          network_cidrs           = list(string)
          secondary_cidrs         = list(string)
          ipv6_network_cidrs      = list(string)
          ipv6_secondary_cidrs    = list(string)
          private_route_table_ids = list(string)
          public_route_table_ids  = list(string)
        })
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
        vpc = object({
          names                   = list(string)
          network_cidrs           = list(string)
          secondary_cidrs         = list(string)
          ipv6_network_cidrs      = list(string)
          ipv6_secondary_cidrs    = list(string)
          private_route_table_ids = list(string)
          public_route_table_ids  = list(string)
        })
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
      distinct(concat(var.full_mesh_trio.one.centralized_router.vpc.names, var.full_mesh_trio.two.centralized_router.vpc.names, var.full_mesh_trio.three.centralized_router.vpc.names))
    ) == length(concat(var.full_mesh_trio.one.centralized_router.vpc.names, var.full_mesh_trio.two.centralized_router.vpc.names, var.full_mesh_trio.three.centralized_router.vpc.names))
    error_message = "All VPC names must be unique across regions."
  }

  validation {
    condition = length(
      distinct(concat(var.full_mesh_trio.one.centralized_router.vpc.network_cidrs, var.full_mesh_trio.two.centralized_router.vpc.network_cidrs, var.full_mesh_trio.three.centralized_router.vpc.network_cidrs))
    ) == length(concat(var.full_mesh_trio.one.centralized_router.vpc.network_cidrs, var.full_mesh_trio.two.centralized_router.vpc.network_cidrs, var.full_mesh_trio.three.centralized_router.vpc.network_cidrs))
    error_message = "All VPC network CIDRs must be unique across regions."
  }

  validation {
    condition = length(
      distinct(concat(var.full_mesh_trio.one.centralized_router.vpc.secondary_cidrs, var.full_mesh_trio.two.centralized_router.vpc.secondary_cidrs, var.full_mesh_trio.three.centralized_router.vpc.secondary_cidrs))
    ) == length(concat(var.full_mesh_trio.one.centralized_router.vpc.secondary_cidrs, var.full_mesh_trio.two.centralized_router.vpc.secondary_cidrs, var.full_mesh_trio.three.centralized_router.vpc.secondary_cidrs))
    error_message = "All VPC secondary CIDRs must be unique across regions."
  }

  validation {
    condition = length(compact(var.full_mesh_trio.one.centralized_router.vpc.ipv6_network_cidrs)) > 0 ? length(
      distinct(concat(var.full_mesh_trio.one.centralized_router.vpc.ipv6_network_cidrs, var.full_mesh_trio.two.centralized_router.vpc.ipv6_network_cidrs, var.full_mesh_trio.three.centralized_router.vpc.ipv6_network_cidrs))
    ) == length(concat(var.full_mesh_trio.one.centralized_router.vpc.ipv6_network_cidrs, var.full_mesh_trio.two.centralized_router.vpc.ipv6_network_cidrs, var.full_mesh_trio.three.centralized_router.vpc.ipv6_network_cidrs)) : true
    error_message = "All VPC IPv6 network CIDRs must be unique across regions."
  }

  validation {
    condition = length(
      distinct(concat(var.full_mesh_trio.one.centralized_router.vpc.ipv6_secondary_cidrs, var.full_mesh_trio.two.centralized_router.vpc.ipv6_secondary_cidrs, var.full_mesh_trio.three.centralized_router.vpc.ipv6_secondary_cidrs))
    ) == length(concat(var.full_mesh_trio.one.centralized_router.vpc.ipv6_secondary_cidrs, var.full_mesh_trio.two.centralized_router.vpc.ipv6_secondary_cidrs, var.full_mesh_trio.three.centralized_router.vpc.ipv6_secondary_cidrs))
    error_message = "All VPC IPv6 secondary CIDRs must be unique across regions."
  }
}

variable "tags" {
  description = "Additional Tags"
  type        = map(string)
  default     = {}
}
