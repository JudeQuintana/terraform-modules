variable "env_prefix" {
  description = "prod, stage, test"
  type        = string
}

variable "mega_mesh" {
  description = "mega mesh configuration"
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
          private_route_table_ids = list(string)
          public_route_table_ids  = list(string)
        })
      })
    })
    four = object({
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
          private_route_table_ids = list(string)
          public_route_table_ids  = list(string)
        })
      })
    })
    five = object({
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
          private_route_table_ids = list(string)
          public_route_table_ids  = list(string)
        })
      })
    })
    six = object({
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
          private_route_table_ids = list(string)
          public_route_table_ids  = list(string)
        })
      })
    })
    seven = object({
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
          private_route_table_ids = list(string)
          public_route_table_ids  = list(string)
        })
      })
    })
    eight = object({
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
          private_route_table_ids = list(string)
          public_route_table_ids  = list(string)
        })
      })
    })
    nine = object({
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
          private_route_table_ids = list(string)
          public_route_table_ids  = list(string)
        })
      })
    })
    ten = object({
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
          private_route_table_ids = list(string)
          public_route_table_ids  = list(string)
        })
      })
    })
  })

  validation {
    condition = length(
      distinct([var.mega_mesh.one.centralized_router.name, var.mega_mesh.two.centralized_router.name, var.mega_mesh.three.centralized_router.name, var.mega_mesh.four.centralized_router.name, var.mega_mesh.five.centralized_router.name, var.mega_mesh.six.centralized_router.name, var.mega_mesh.seven.centralized_router.name, var.mega_mesh.eight.centralized_router.name, var.mega_mesh.nine.centralized_router.name, var.mega_mesh.ten.centralized_router.name])
    ) == length([var.mega_mesh.one.centralized_router.name, var.mega_mesh.two.centralized_router.name, var.mega_mesh.three.centralized_router.name, var.mega_mesh.four.centralized_router.name, var.mega_mesh.five.centralized_router.name, var.mega_mesh.six.centralized_router.name, var.mega_mesh.seven.centralized_router.name, var.mega_mesh.eight.centralized_router.name, var.mega_mesh.nine.centralized_router.name, var.mega_mesh.ten.centralized_router.name])
    error_message = "All Centralized Routers must have a unique names across regions."
  }

  validation {
    condition = length(
      distinct([var.mega_mesh.one.centralized_router.amazon_side_asn, var.mega_mesh.two.centralized_router.amazon_side_asn, var.mega_mesh.three.centralized_router.amazon_side_asn, var.mega_mesh.four.centralized_router.amazon_side_asn, var.mega_mesh.five.centralized_router.amazon_side_asn, var.mega_mesh.six.centralized_router.amazon_side_asn, var.mega_mesh.seven.centralized_router.amazon_side_asn, var.mega_mesh.eight.centralized_router.amazon_side_asn, var.mega_mesh.nine.centralized_router.amazon_side_asn, var.mega_mesh.ten.centralized_router.amazon_side_asn])
    ) == length([var.mega_mesh.one.centralized_router.amazon_side_asn, var.mega_mesh.two.centralized_router.amazon_side_asn, var.mega_mesh.three.centralized_router.amazon_side_asn, var.mega_mesh.four.centralized_router.amazon_side_asn, var.mega_mesh.five.centralized_router.amazon_side_asn, var.mega_mesh.six.centralized_router.amazon_side_asn, var.mega_mesh.seven.centralized_router.amazon_side_asn, var.mega_mesh.eight.centralized_router.amazon_side_asn, var.mega_mesh.nine.centralized_router.amazon_side_asn, var.mega_mesh.ten.centralized_router.amazon_side_asn])
    error_message = "All Centralized Routers must have a unique amazon side ASN number across regions."
  }

  validation {
    condition     = length(distinct([var.mega_mesh.one.centralized_router.account_id, var.mega_mesh.two.centralized_router.account_id, var.mega_mesh.three.centralized_router.account_id, var.mega_mesh.four.centralized_router.account_id, var.mega_mesh.five.centralized_router.account_id, var.mega_mesh.six.centralized_router.account_id, var.mega_mesh.seven.centralized_router.account_id, var.mega_mesh.eight.centralized_router.account_id, var.mega_mesh.nine.centralized_router.account_id, var.mega_mesh.ten.centralized_router.account_id])) <= 1
    error_message = "All Centralized Routers must have the same account id as each other, no cross account at this time."
  }

  validation {
    condition = length(
      distinct(concat(var.mega_mesh.one.centralized_router.vpc.names, var.mega_mesh.two.centralized_router.vpc.names, var.mega_mesh.three.centralized_router.vpc.names, var.mega_mesh.four.centralized_router.vpc.names, var.mega_mesh.five.centralized_router.vpc.names, var.mega_mesh.six.centralized_router.vpc.names, var.mega_mesh.seven.centralized_router.vpc.names, var.mega_mesh.eight.centralized_router.vpc.names, var.mega_mesh.nine.centralized_router.vpc.names, var.mega_mesh.ten.centralized_router.vpc.names))
    ) == length(concat(var.mega_mesh.one.centralized_router.vpc.names, var.mega_mesh.two.centralized_router.vpc.names, var.mega_mesh.three.centralized_router.vpc.names, var.mega_mesh.four.centralized_router.vpc.names, var.mega_mesh.five.centralized_router.vpc.names, var.mega_mesh.six.centralized_router.vpc.names, var.mega_mesh.seven.centralized_router.vpc.names, var.mega_mesh.eight.centralized_router.vpc.names, var.mega_mesh.nine.centralized_router.vpc.names, var.mega_mesh.ten.centralized_router.vpc.names))
    error_message = "All VPC names must be unique across regions."
  }

  validation {
    condition = length(
      distinct(concat(var.mega_mesh.one.centralized_router.vpc.network_cidrs, var.mega_mesh.two.centralized_router.vpc.network_cidrs, var.mega_mesh.three.centralized_router.vpc.network_cidrs, var.mega_mesh.four.centralized_router.vpc.network_cidrs, var.mega_mesh.five.centralized_router.vpc.network_cidrs, var.mega_mesh.six.centralized_router.vpc.network_cidrs, var.mega_mesh.seven.centralized_router.vpc.network_cidrs, var.mega_mesh.eight.centralized_router.vpc.network_cidrs, var.mega_mesh.nine.centralized_router.vpc.network_cidrs, var.mega_mesh.ten.centralized_router.vpc.network_cidrs))
    ) == length(concat(var.mega_mesh.one.centralized_router.vpc.network_cidrs, var.mega_mesh.two.centralized_router.vpc.network_cidrs, var.mega_mesh.three.centralized_router.vpc.network_cidrs, var.mega_mesh.four.centralized_router.vpc.network_cidrs, var.mega_mesh.five.centralized_router.vpc.network_cidrs, var.mega_mesh.six.centralized_router.vpc.network_cidrs, var.mega_mesh.seven.centralized_router.vpc.network_cidrs, var.mega_mesh.eight.centralized_router.vpc.network_cidrs, var.mega_mesh.nine.centralized_router.vpc.network_cidrs, var.mega_mesh.ten.centralized_router.vpc.network_cidrs))
    error_message = "All VPC network CIDRs must be unique across regions."
  }
}

variable "tags" {
  description = "Additional Tags"
  type        = map(string)
  default     = {}
}

