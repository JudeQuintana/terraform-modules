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

  validation {
    condition     = contains(["allow", "deny"], var.super_router.routing_policy.default)
    error_message = "Policy default must be \"allow\" or \"deny\"."
  }

  validation {
    condition = length(
      distinct(flatten([for vpcs in var.super_router.routing_policy.segments : [for vpc in vpcs : vpc.network_cidr]]))
    ) == length(flatten([for vpcs in var.super_router.routing_policy.segments : [for vpc in vpcs : vpc.network_cidr]]))
    error_message = format(
      "Routing policy has VPCs in multiple segments: %s. Each VPC (network_cidr) must appear in only one segment or use allow = [] to create explicit allows across segments.",
      join(", ", [
        for cidr in distinct(flatten([for vpcs in var.super_router.routing_policy.segments : [for vpc in vpcs : vpc.network_cidr]])) : cidr
        if length(flatten([for vpcs in var.super_router.routing_policy.segments : [for vpc in vpcs : vpc.network_cidr if vpc.network_cidr == cidr]])) > 1
      ])
    )
  }

  validation {
    condition = alltrue(concat(
      [for rule in var.super_router.routing_policy.deny : contains(concat(flatten([for cr in var.super_router.local.centralized_routers : [for vpc in cr.vpcs : vpc.network_cidr]]), flatten([for cr in var.super_router.peer.centralized_routers : [for vpc in cr.vpcs : vpc.network_cidr]])), rule.from.network_cidr)],
      [for rule in var.super_router.routing_policy.deny : contains(concat(flatten([for cr in var.super_router.local.centralized_routers : [for vpc in cr.vpcs : vpc.network_cidr]]), flatten([for cr in var.super_router.peer.centralized_routers : [for vpc in cr.vpcs : vpc.network_cidr]])), rule.to.network_cidr)],
      [for rule in var.super_router.routing_policy.allow : contains(concat(flatten([for cr in var.super_router.local.centralized_routers : [for vpc in cr.vpcs : vpc.network_cidr]]), flatten([for cr in var.super_router.peer.centralized_routers : [for vpc in cr.vpcs : vpc.network_cidr]])), rule.from.network_cidr)],
      [for rule in var.super_router.routing_policy.allow : contains(concat(flatten([for cr in var.super_router.local.centralized_routers : [for vpc in cr.vpcs : vpc.network_cidr]]), flatten([for cr in var.super_router.peer.centralized_routers : [for vpc in cr.vpcs : vpc.network_cidr]])), rule.to.network_cidr)],
      flatten([for vpcs in var.super_router.routing_policy.segments : [
        for vpc in vpcs : contains(concat(flatten([for cr in var.super_router.local.centralized_routers : [for v in cr.vpcs : v.network_cidr]]), flatten([for cr in var.super_router.peer.centralized_routers : [for v in cr.vpcs : v.network_cidr]])), vpc.network_cidr)
      ]]),
    ))
    error_message = format(
      "Routing policy references network_cidrs not in vpcs: %s. Allow/deny/segment rules can only reference VPCs in this router's scope.",
      join(", ", distinct(concat(
        [for rule in var.super_router.routing_policy.deny : rule.from.network_cidr if !contains(concat(flatten([for cr in var.super_router.local.centralized_routers : [for vpc in cr.vpcs : vpc.network_cidr]]), flatten([for cr in var.super_router.peer.centralized_routers : [for vpc in cr.vpcs : vpc.network_cidr]])), rule.from.network_cidr)],
        [for rule in var.super_router.routing_policy.deny : rule.to.network_cidr if !contains(concat(flatten([for cr in var.super_router.local.centralized_routers : [for vpc in cr.vpcs : vpc.network_cidr]]), flatten([for cr in var.super_router.peer.centralized_routers : [for vpc in cr.vpcs : vpc.network_cidr]])), rule.to.network_cidr)],
        [for rule in var.super_router.routing_policy.allow : rule.from.network_cidr if !contains(concat(flatten([for cr in var.super_router.local.centralized_routers : [for vpc in cr.vpcs : vpc.network_cidr]]), flatten([for cr in var.super_router.peer.centralized_routers : [for vpc in cr.vpcs : vpc.network_cidr]])), rule.from.network_cidr)],
        [for rule in var.super_router.routing_policy.allow : rule.to.network_cidr if !contains(concat(flatten([for cr in var.super_router.local.centralized_routers : [for vpc in cr.vpcs : vpc.network_cidr]]), flatten([for cr in var.super_router.peer.centralized_routers : [for vpc in cr.vpcs : vpc.network_cidr]])), rule.to.network_cidr)],
        flatten([for vpcs in var.super_router.routing_policy.segments : [
          for vpc in vpcs : vpc.network_cidr if !contains(concat(flatten([for cr in var.super_router.local.centralized_routers : [for v in cr.vpcs : v.network_cidr]]), flatten([for cr in var.super_router.peer.centralized_routers : [for v in cr.vpcs : v.network_cidr]])), vpc.network_cidr)
        ]]),
    ))))
  }

  validation {
    condition     = var.super_router.inspect.equivalence.equivalent_routing_policy != null ? contains(["allow", "deny"], var.super_router.inspect.equivalence.equivalent_routing_policy.default) : true
    error_message = "Equivalent routing policy default must be \"allow\" or \"deny\"."
  }

  validation {
    condition = var.super_router.inspect.equivalence.equivalent_routing_policy != null ? length(
      distinct(flatten([for vpcs in var.super_router.inspect.equivalence.equivalent_routing_policy.segments : [for vpc in vpcs : vpc.network_cidr]]))
    ) == length(flatten([for vpcs in var.super_router.inspect.equivalence.equivalent_routing_policy.segments : [for vpc in vpcs : vpc.network_cidr]])) : true
    error_message = var.super_router.inspect.equivalence.equivalent_routing_policy != null ? format(
      "Equivalent routing policy has VPCs in multiple segments: %s. Each VPC (network_cidr) must appear in only one segment.",
      join(", ", [
        for cidr in distinct(flatten([for vpcs in var.super_router.inspect.equivalence.equivalent_routing_policy.segments : [for vpc in vpcs : vpc.network_cidr]])) : cidr
        if length(flatten([for vpcs in var.super_router.inspect.equivalence.equivalent_routing_policy.segments : [for vpc in vpcs : vpc.network_cidr if vpc.network_cidr == cidr]])) > 1
      ])
    ) : "n/a"
  }

  validation {
    condition = var.super_router.inspect.equivalence.equivalent_routing_policy != null ? alltrue(concat(
      [for rule in var.super_router.inspect.equivalence.equivalent_routing_policy.deny : contains(concat(flatten([for cr in var.super_router.local.centralized_routers : [for vpc in cr.vpcs : vpc.network_cidr]]), flatten([for cr in var.super_router.peer.centralized_routers : [for vpc in cr.vpcs : vpc.network_cidr]])), rule.from.network_cidr)],
      [for rule in var.super_router.inspect.equivalence.equivalent_routing_policy.deny : contains(concat(flatten([for cr in var.super_router.local.centralized_routers : [for vpc in cr.vpcs : vpc.network_cidr]]), flatten([for cr in var.super_router.peer.centralized_routers : [for vpc in cr.vpcs : vpc.network_cidr]])), rule.to.network_cidr)],
      [for rule in var.super_router.inspect.equivalence.equivalent_routing_policy.allow : contains(concat(flatten([for cr in var.super_router.local.centralized_routers : [for vpc in cr.vpcs : vpc.network_cidr]]), flatten([for cr in var.super_router.peer.centralized_routers : [for vpc in cr.vpcs : vpc.network_cidr]])), rule.from.network_cidr)],
      [for rule in var.super_router.inspect.equivalence.equivalent_routing_policy.allow : contains(concat(flatten([for cr in var.super_router.local.centralized_routers : [for vpc in cr.vpcs : vpc.network_cidr]]), flatten([for cr in var.super_router.peer.centralized_routers : [for vpc in cr.vpcs : vpc.network_cidr]])), rule.to.network_cidr)],
      flatten([for vpcs in var.super_router.inspect.equivalence.equivalent_routing_policy.segments : [
        for vpc in vpcs : contains(concat(flatten([for cr in var.super_router.local.centralized_routers : [for v in cr.vpcs : v.network_cidr]]), flatten([for cr in var.super_router.peer.centralized_routers : [for v in cr.vpcs : v.network_cidr]])), vpc.network_cidr)
      ]]),
    )) : true
    error_message = var.super_router.inspect.equivalence.equivalent_routing_policy != null ? format(
      "Equivalent routing policy references network_cidrs not in vpcs: %s. Allow/deny/segment rules can only reference VPCs in this router's scope.",
      join(", ", distinct(concat(
        [for rule in var.super_router.inspect.equivalence.equivalent_routing_policy.deny : rule.from.network_cidr if !contains(concat(flatten([for cr in var.super_router.local.centralized_routers : [for vpc in cr.vpcs : vpc.network_cidr]]), flatten([for cr in var.super_router.peer.centralized_routers : [for vpc in cr.vpcs : vpc.network_cidr]])), rule.from.network_cidr)],
        [for rule in var.super_router.inspect.equivalence.equivalent_routing_policy.deny : rule.to.network_cidr if !contains(concat(flatten([for cr in var.super_router.local.centralized_routers : [for vpc in cr.vpcs : vpc.network_cidr]]), flatten([for cr in var.super_router.peer.centralized_routers : [for vpc in cr.vpcs : vpc.network_cidr]])), rule.to.network_cidr)],
        [for rule in var.super_router.inspect.equivalence.equivalent_routing_policy.allow : rule.from.network_cidr if !contains(concat(flatten([for cr in var.super_router.local.centralized_routers : [for vpc in cr.vpcs : vpc.network_cidr]]), flatten([for cr in var.super_router.peer.centralized_routers : [for vpc in cr.vpcs : vpc.network_cidr]])), rule.from.network_cidr)],
        [for rule in var.super_router.inspect.equivalence.equivalent_routing_policy.allow : rule.to.network_cidr if !contains(concat(flatten([for cr in var.super_router.local.centralized_routers : [for vpc in cr.vpcs : vpc.network_cidr]]), flatten([for cr in var.super_router.peer.centralized_routers : [for vpc in cr.vpcs : vpc.network_cidr]])), rule.to.network_cidr)],
        flatten([for vpcs in var.super_router.inspect.equivalence.equivalent_routing_policy.segments : [
          for vpc in vpcs : vpc.network_cidr if !contains(concat(flatten([for cr in var.super_router.local.centralized_routers : [for v in cr.vpcs : v.network_cidr]]), flatten([for cr in var.super_router.peer.centralized_routers : [for v in cr.vpcs : v.network_cidr]])), vpc.network_cidr)
        ]]),
    )))) : "n/a"
  }
}

variable "tags" {
  description = "Additional Tags"
  type        = map(string)
  default     = {}
}
