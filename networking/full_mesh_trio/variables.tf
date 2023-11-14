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
          names         = list(string)
          network_cidrs = list(string)
          routes = list(object({
            route_table_id         = string
            destination_cidr_block = string
            transit_gateway_id     = string
          }))
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
          names         = list(string)
          network_cidrs = list(string)
          routes = list(object({
            route_table_id         = string
            destination_cidr_block = string
            transit_gateway_id     = string
          }))
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
          names         = list(string)
          network_cidrs = list(string)
          routes = list(object({
            route_table_id         = string
            destination_cidr_block = string
            transit_gateway_id     = string
          }))
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
    condition = ((
      var.full_mesh_trio.one.centralized_router.amazon_side_asn >= 64512 && var.full_mesh_trio.one.centralized_router.amazon_side_asn <= 65534
      ) && (
      var.full_mesh_trio.two.centralized_router.amazon_side_asn >= 64512 && var.full_mesh_trio.two.centralized_router.amazon_side_asn <= 65534
      ) && (
      var.full_mesh_trio.three.centralized_router.amazon_side_asn >= 64512 && var.full_mesh_trio.three.centralized_router.amazon_side_asn <= 65534
      )) || ((
      var.full_mesh_trio.one.centralized_router.amazon_side_asn >= 4200000000 && var.full_mesh_trio.one.centralized_router.amazon_side_asn <= 4294967294
      ) && (
      var.full_mesh_trio.two.centralized_router.amazon_side_asn >= 4200000000 && var.full_mesh_trio.two.centralized_router.amazon_side_asn <= 4294967294
      ) && (
      var.full_mesh_trio.three.centralized_router.amazon_side_asn >= 4200000000 && var.full_mesh_trio.three.centralized_router.amazon_side_asn <= 4294967294
    ))

    error_message = "All Centralized Routers amazon side ASNs should be within 64512 to 65534 (inclusive) for 16-bit ASNs or 4200000000 to 4294967294 (inclusive) for 32-bit ASNs.."
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
}

variable "tags" {
  description = "Additional Tags"
  type        = map(string)
  default     = {}
}
