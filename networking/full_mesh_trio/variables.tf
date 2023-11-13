variable "env_prefix" {
  description = "prod, stage, test"
  type        = string
}

variable "region_az_labels" {
  description = "Region and AZ names mapped to short naming conventions for labeling"
  type        = map(string)
}

variable "full_mesh_trio" {
  description = "full mesh trio configuration"
  type = object({
    name = string
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
}

variable "tags" {
  description = "Additional Tags"
  type        = map(string)
  default     = {}
}
