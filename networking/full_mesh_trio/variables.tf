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
        vpcs = optional(map(object({
          id                      = string
          name                    = string
          network_cidr            = string
          secondary_cidrs         = optional(list(string), [])
          ipv6_network_cidr       = optional(string)
          ipv6_secondary_cidrs    = optional(list(string), [])
          private_route_table_ids = list(string)
          public_route_table_ids  = list(string)
        })), {})
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
        vpcs = optional(map(object({
          id                      = string
          name                    = string
          network_cidr            = string
          secondary_cidrs         = optional(list(string), [])
          ipv6_network_cidr       = optional(string)
          ipv6_secondary_cidrs    = optional(list(string), [])
          private_route_table_ids = list(string)
          public_route_table_ids  = list(string)
        })), {})
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
        vpcs = optional(map(object({
          id                      = string
          name                    = string
          network_cidr            = string
          secondary_cidrs         = optional(list(string), [])
          ipv6_network_cidr       = optional(string)
          ipv6_secondary_cidrs    = optional(list(string), [])
          private_route_table_ids = list(string)
          public_route_table_ids  = list(string)
        })), {})
      })
    })
    routing_policy = object({
      default = string
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
    inspect = optional(object({
      reachability = optional(bool, false)
      diagnostics  = optional(bool, false)
      provenance   = optional(bool, false)
      policy_diff = optional(object({
        previous_reachability = optional(map(string))
      }), {})
      equivalence = optional(object({
        equivalent_routing_policy = optional(object({
          default = string
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
        }))
      }), {})
    }), {})
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
      distinct(concat([for this in var.full_mesh_trio.one.centralized_router.vpcs : this.name], [for this in var.full_mesh_trio.two.centralized_router.vpcs : this.name], [for this in var.full_mesh_trio.three.centralized_router.vpcs : this.name]))
    ) == length(concat([for this in var.full_mesh_trio.one.centralized_router.vpcs : this.name], [for this in var.full_mesh_trio.two.centralized_router.vpcs : this.name], [for this in var.full_mesh_trio.three.centralized_router.vpcs : this.name]))
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

  validation {
    condition     = contains(["allow", "deny"], var.full_mesh_trio.routing_policy.default)
    error_message = "Policy default must be \"allow\" or \"deny\"."
  }

  validation {
    condition = length(
      distinct(flatten([for vpcs in var.full_mesh_trio.routing_policy.segments : [for vpc in vpcs : vpc.network_cidr]]))
    ) == length(flatten([for vpcs in var.full_mesh_trio.routing_policy.segments : [for vpc in vpcs : vpc.network_cidr]]))
    error_message = format(
      "Routing policy has VPCs in multiple segments: %s. Each VPC (network_cidr) must appear in only one segment or use allow = [] to create explicit allows across segments.",
      join(", ", [
        for cidr in distinct(flatten([for vpcs in var.full_mesh_trio.routing_policy.segments : [for vpc in vpcs : vpc.network_cidr]])) : cidr
        if length(flatten([for vpcs in var.full_mesh_trio.routing_policy.segments : [for vpc in vpcs : vpc.network_cidr if vpc.network_cidr == cidr]])) > 1
      ])
    )
  }

  validation {
    condition = alltrue(concat(
      [for rule in var.full_mesh_trio.routing_policy.deny : contains(concat([for vpc in var.full_mesh_trio.one.centralized_router.vpcs : vpc.network_cidr], [for vpc in var.full_mesh_trio.two.centralized_router.vpcs : vpc.network_cidr], [for vpc in var.full_mesh_trio.three.centralized_router.vpcs : vpc.network_cidr]), rule.from.network_cidr)],
      [for rule in var.full_mesh_trio.routing_policy.deny : contains(concat([for vpc in var.full_mesh_trio.one.centralized_router.vpcs : vpc.network_cidr], [for vpc in var.full_mesh_trio.two.centralized_router.vpcs : vpc.network_cidr], [for vpc in var.full_mesh_trio.three.centralized_router.vpcs : vpc.network_cidr]), rule.to.network_cidr)],
      [for rule in var.full_mesh_trio.routing_policy.allow : contains(concat([for vpc in var.full_mesh_trio.one.centralized_router.vpcs : vpc.network_cidr], [for vpc in var.full_mesh_trio.two.centralized_router.vpcs : vpc.network_cidr], [for vpc in var.full_mesh_trio.three.centralized_router.vpcs : vpc.network_cidr]), rule.from.network_cidr)],
      [for rule in var.full_mesh_trio.routing_policy.allow : contains(concat([for vpc in var.full_mesh_trio.one.centralized_router.vpcs : vpc.network_cidr], [for vpc in var.full_mesh_trio.two.centralized_router.vpcs : vpc.network_cidr], [for vpc in var.full_mesh_trio.three.centralized_router.vpcs : vpc.network_cidr]), rule.to.network_cidr)],
      flatten([for vpcs in var.full_mesh_trio.routing_policy.segments : [
        for vpc in vpcs : contains(concat([for v in var.full_mesh_trio.one.centralized_router.vpcs : v.network_cidr], [for v in var.full_mesh_trio.two.centralized_router.vpcs : v.network_cidr], [for v in var.full_mesh_trio.three.centralized_router.vpcs : v.network_cidr]), vpc.network_cidr)
      ]]),
    ))
    error_message = format(
      "Routing policy references network_cidrs not in vpcs: %s. Allow/deny/segment rules can only reference VPCs in this IR's scope.",
      join(", ", distinct(concat(
        [for rule in var.full_mesh_trio.routing_policy.deny : rule.from.network_cidr if !contains(concat([for vpc in var.full_mesh_trio.one.centralized_router.vpcs : vpc.network_cidr], [for vpc in var.full_mesh_trio.two.centralized_router.vpcs : vpc.network_cidr], [for vpc in var.full_mesh_trio.three.centralized_router.vpcs : vpc.network_cidr]), rule.from.network_cidr)],
        [for rule in var.full_mesh_trio.routing_policy.deny : rule.to.network_cidr if !contains(concat([for vpc in var.full_mesh_trio.one.centralized_router.vpcs : vpc.network_cidr], [for vpc in var.full_mesh_trio.two.centralized_router.vpcs : vpc.network_cidr], [for vpc in var.full_mesh_trio.three.centralized_router.vpcs : vpc.network_cidr]), rule.to.network_cidr)],
        [for rule in var.full_mesh_trio.routing_policy.allow : rule.from.network_cidr if !contains(concat([for vpc in var.full_mesh_trio.one.centralized_router.vpcs : vpc.network_cidr], [for vpc in var.full_mesh_trio.two.centralized_router.vpcs : vpc.network_cidr], [for vpc in var.full_mesh_trio.three.centralized_router.vpcs : vpc.network_cidr]), rule.from.network_cidr)],
        [for rule in var.full_mesh_trio.routing_policy.allow : rule.to.network_cidr if !contains(concat([for vpc in var.full_mesh_trio.one.centralized_router.vpcs : vpc.network_cidr], [for vpc in var.full_mesh_trio.two.centralized_router.vpcs : vpc.network_cidr], [for vpc in var.full_mesh_trio.three.centralized_router.vpcs : vpc.network_cidr]), rule.to.network_cidr)],
        flatten([for vpcs in var.full_mesh_trio.routing_policy.segments : [
          for vpc in vpcs : vpc.network_cidr if !contains(concat([for v in var.full_mesh_trio.one.centralized_router.vpcs : v.network_cidr], [for v in var.full_mesh_trio.two.centralized_router.vpcs : v.network_cidr], [for v in var.full_mesh_trio.three.centralized_router.vpcs : v.network_cidr]), vpc.network_cidr)
        ]]),
    ))))
  }

  validation {
    condition     = var.full_mesh_trio.inspect.equivalence.equivalent_routing_policy != null ? contains(["allow", "deny"], var.full_mesh_trio.inspect.equivalence.equivalent_routing_policy.default) : true
    error_message = "Equivalent routing policy default must be \"allow\" or \"deny\"."
  }

  validation {
    condition = var.full_mesh_trio.inspect.equivalence.equivalent_routing_policy != null ? length(
      distinct(flatten([for vpcs in var.full_mesh_trio.inspect.equivalence.equivalent_routing_policy.segments : [for vpc in vpcs : vpc.network_cidr]]))
    ) == length(flatten([for vpcs in var.full_mesh_trio.inspect.equivalence.equivalent_routing_policy.segments : [for vpc in vpcs : vpc.network_cidr]])) : true
    error_message = var.full_mesh_trio.inspect.equivalence.equivalent_routing_policy != null ? format(
      "Equivalent routing policy has VPCs in multiple segments: %s. Each VPC (network_cidr) must appear in only one segment.",
      join(", ", [
        for cidr in distinct(flatten([for vpcs in var.full_mesh_trio.inspect.equivalence.equivalent_routing_policy.segments : [for vpc in vpcs : vpc.network_cidr]])) : cidr
        if length(flatten([for vpcs in var.full_mesh_trio.inspect.equivalence.equivalent_routing_policy.segments : [for vpc in vpcs : vpc.network_cidr if vpc.network_cidr == cidr]])) > 1
      ])
    ) : "n/a"
  }

  validation {
    condition = var.full_mesh_trio.inspect.equivalence.equivalent_routing_policy != null ? alltrue(concat(
      [for rule in var.full_mesh_trio.inspect.equivalence.equivalent_routing_policy.deny : contains(concat([for vpc in var.full_mesh_trio.one.centralized_router.vpcs : vpc.network_cidr], [for vpc in var.full_mesh_trio.two.centralized_router.vpcs : vpc.network_cidr], [for vpc in var.full_mesh_trio.three.centralized_router.vpcs : vpc.network_cidr]), rule.from.network_cidr)],
      [for rule in var.full_mesh_trio.inspect.equivalence.equivalent_routing_policy.deny : contains(concat([for vpc in var.full_mesh_trio.one.centralized_router.vpcs : vpc.network_cidr], [for vpc in var.full_mesh_trio.two.centralized_router.vpcs : vpc.network_cidr], [for vpc in var.full_mesh_trio.three.centralized_router.vpcs : vpc.network_cidr]), rule.to.network_cidr)],
      [for rule in var.full_mesh_trio.inspect.equivalence.equivalent_routing_policy.allow : contains(concat([for vpc in var.full_mesh_trio.one.centralized_router.vpcs : vpc.network_cidr], [for vpc in var.full_mesh_trio.two.centralized_router.vpcs : vpc.network_cidr], [for vpc in var.full_mesh_trio.three.centralized_router.vpcs : vpc.network_cidr]), rule.from.network_cidr)],
      [for rule in var.full_mesh_trio.inspect.equivalence.equivalent_routing_policy.allow : contains(concat([for vpc in var.full_mesh_trio.one.centralized_router.vpcs : vpc.network_cidr], [for vpc in var.full_mesh_trio.two.centralized_router.vpcs : vpc.network_cidr], [for vpc in var.full_mesh_trio.three.centralized_router.vpcs : vpc.network_cidr]), rule.to.network_cidr)],
      flatten([for vpcs in var.full_mesh_trio.inspect.equivalence.equivalent_routing_policy.segments : [
        for vpc in vpcs : contains(concat([for v in var.full_mesh_trio.one.centralized_router.vpcs : v.network_cidr], [for v in var.full_mesh_trio.two.centralized_router.vpcs : v.network_cidr], [for v in var.full_mesh_trio.three.centralized_router.vpcs : v.network_cidr]), vpc.network_cidr)
      ]]),
    )) : true
    error_message = var.full_mesh_trio.inspect.equivalence.equivalent_routing_policy != null ? format(
      "Equivalent routing policy references network_cidrs not in vpcs: %s. Allow/deny/segment rules can only reference VPCs in this router's scope.",
      join(", ", distinct(concat(
        [for rule in var.full_mesh_trio.inspect.equivalence.equivalent_routing_policy.deny : rule.from.network_cidr if !contains(concat([for vpc in var.full_mesh_trio.one.centralized_router.vpcs : vpc.network_cidr], [for vpc in var.full_mesh_trio.two.centralized_router.vpcs : vpc.network_cidr], [for vpc in var.full_mesh_trio.three.centralized_router.vpcs : vpc.network_cidr]), rule.from.network_cidr)],
        [for rule in var.full_mesh_trio.inspect.equivalence.equivalent_routing_policy.deny : rule.to.network_cidr if !contains(concat([for vpc in var.full_mesh_trio.one.centralized_router.vpcs : vpc.network_cidr], [for vpc in var.full_mesh_trio.two.centralized_router.vpcs : vpc.network_cidr], [for vpc in var.full_mesh_trio.three.centralized_router.vpcs : vpc.network_cidr]), rule.to.network_cidr)],
        [for rule in var.full_mesh_trio.inspect.equivalence.equivalent_routing_policy.allow : rule.from.network_cidr if !contains(concat([for vpc in var.full_mesh_trio.one.centralized_router.vpcs : vpc.network_cidr], [for vpc in var.full_mesh_trio.two.centralized_router.vpcs : vpc.network_cidr], [for vpc in var.full_mesh_trio.three.centralized_router.vpcs : vpc.network_cidr]), rule.from.network_cidr)],
        [for rule in var.full_mesh_trio.inspect.equivalence.equivalent_routing_policy.allow : rule.to.network_cidr if !contains(concat([for vpc in var.full_mesh_trio.one.centralized_router.vpcs : vpc.network_cidr], [for vpc in var.full_mesh_trio.two.centralized_router.vpcs : vpc.network_cidr], [for vpc in var.full_mesh_trio.three.centralized_router.vpcs : vpc.network_cidr]), rule.to.network_cidr)],
        flatten([for vpcs in var.full_mesh_trio.inspect.equivalence.equivalent_routing_policy.segments : [
          for vpc in vpcs : vpc.network_cidr if !contains(concat([for v in var.full_mesh_trio.one.centralized_router.vpcs : v.network_cidr], [for v in var.full_mesh_trio.two.centralized_router.vpcs : v.network_cidr], [for v in var.full_mesh_trio.three.centralized_router.vpcs : v.network_cidr]), vpc.network_cidr)
        ]]),
    )))) : "n/a"
  }
}

variable "tags" {
  description = "Additional Tags"
  type        = map(string)
  default     = {}
}
