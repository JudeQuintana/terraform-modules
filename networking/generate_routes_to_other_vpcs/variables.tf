variable "generate_routes_to_other_vpcs" {
  description = "Configuration for scope-agnostic route compilation: VPCs, routing policy, and optional inspect inputs."
  type = object({
    vpcs = map(object({
      network_cidr            = string
      secondary_cidrs         = optional(list(string), [])
      ipv6_network_cidr       = optional(string)
      ipv6_secondary_cidrs    = optional(list(string), [])
      private_route_table_ids = list(string)
      public_route_table_ids  = list(string)
    }))
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
    previous_reachability = optional(map(string))
    assertions = optional(object({
      must_deny = optional(list(object({
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
      must_permit = optional(list(object({
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
    }))
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
  })

  validation {
    condition     = contains(["allow", "deny"], var.generate_routes_to_other_vpcs.routing_policy.default)
    error_message = "Policy default must be \"allow\" or \"deny\"."
  }

  validation {
    condition = length(
      distinct(flatten([for vpcs in var.generate_routes_to_other_vpcs.routing_policy.segments : [for vpc in vpcs : vpc.network_cidr]]))
    ) == length(flatten([for vpcs in var.generate_routes_to_other_vpcs.routing_policy.segments : [for vpc in vpcs : vpc.network_cidr]]))
    error_message = "A VPC cannot belong to multiple segments. Each VPC (network_cidr) must appear in only one segment or use allow = [] to create explicit allows across segments."
  }

  validation {
    condition     = alltrue([for this in var.generate_routes_to_other_vpcs.vpcs : can(cidrnetmask(this.network_cidr))])
    error_message = "The VPC network_cidr must be in valid IPv4 CIDR notation ie 10.46.0.0/20, x.x.x.x/xx . Check for typos."
  }

  validation {
    condition = alltrue(flatten([
      for this in var.generate_routes_to_other_vpcs.vpcs : [
        for secondary_cidr in this.secondary_cidrs :
        can(cidrnetmask(secondary_cidr))
    ]]))
    error_message = "Each Secondary VPC CIDR valid IPv4 CIDR notation (ie x.x.x.x/xx -> 10.46.0.0/20). Check for typos."
  }

  validation {
    condition = alltrue(concat(
      [for rule in var.generate_routes_to_other_vpcs.routing_policy.deny : contains([for vpc in var.generate_routes_to_other_vpcs.vpcs : vpc.network_cidr], rule.from.network_cidr)],
      [for rule in var.generate_routes_to_other_vpcs.routing_policy.deny : contains([for vpc in var.generate_routes_to_other_vpcs.vpcs : vpc.network_cidr], rule.to.network_cidr)],
      [for rule in var.generate_routes_to_other_vpcs.routing_policy.allow : contains([for vpc in var.generate_routes_to_other_vpcs.vpcs : vpc.network_cidr], rule.from.network_cidr)],
      [for rule in var.generate_routes_to_other_vpcs.routing_policy.allow : contains([for vpc in var.generate_routes_to_other_vpcs.vpcs : vpc.network_cidr], rule.to.network_cidr)],
      flatten([for vpcs in var.generate_routes_to_other_vpcs.routing_policy.segments : [
        for vpc in vpcs : contains([for v in var.generate_routes_to_other_vpcs.vpcs : v.network_cidr], vpc.network_cidr)
      ]]),
    ))
    error_message = format(
      "Routing policy references network_cidrs not in vpcs: %s. Allow/deny/segment rules can only reference VPCs in this router's scope.",
      join(", ", distinct(concat(
        [for rule in var.generate_routes_to_other_vpcs.routing_policy.deny : rule.from.network_cidr if !contains([for vpc in var.generate_routes_to_other_vpcs.vpcs : vpc.network_cidr], rule.from.network_cidr)],
        [for rule in var.generate_routes_to_other_vpcs.routing_policy.deny : rule.to.network_cidr if !contains([for vpc in var.generate_routes_to_other_vpcs.vpcs : vpc.network_cidr], rule.to.network_cidr)],
        [for rule in var.generate_routes_to_other_vpcs.routing_policy.allow : rule.from.network_cidr if !contains([for vpc in var.generate_routes_to_other_vpcs.vpcs : vpc.network_cidr], rule.from.network_cidr)],
        [for rule in var.generate_routes_to_other_vpcs.routing_policy.allow : rule.to.network_cidr if !contains([for vpc in var.generate_routes_to_other_vpcs.vpcs : vpc.network_cidr], rule.to.network_cidr)],
        flatten([for vpcs in var.generate_routes_to_other_vpcs.routing_policy.segments : [
          for vpc in vpcs : vpc.network_cidr if !contains([for v in var.generate_routes_to_other_vpcs.vpcs : v.network_cidr], vpc.network_cidr)
        ]]),
    ))))
  }

  validation {
    condition = var.generate_routes_to_other_vpcs.assertions != null ? alltrue(concat(
      [for rule in var.generate_routes_to_other_vpcs.assertions.must_deny : contains([for vpc in var.generate_routes_to_other_vpcs.vpcs : vpc.network_cidr], rule.from.network_cidr)],
      [for rule in var.generate_routes_to_other_vpcs.assertions.must_deny : contains([for vpc in var.generate_routes_to_other_vpcs.vpcs : vpc.network_cidr], rule.to.network_cidr)],
      [for rule in var.generate_routes_to_other_vpcs.assertions.must_permit : contains([for vpc in var.generate_routes_to_other_vpcs.vpcs : vpc.network_cidr], rule.from.network_cidr)],
      [for rule in var.generate_routes_to_other_vpcs.assertions.must_permit : contains([for vpc in var.generate_routes_to_other_vpcs.vpcs : vpc.network_cidr], rule.to.network_cidr)],
    )) : true
    error_message = var.generate_routes_to_other_vpcs.assertions != null ? format(
      "Assertions reference network_cidrs not in vpcs: %s. Assertions can only reference VPCs in this router's scope.",
      join(", ", distinct(concat(
        [for rule in var.generate_routes_to_other_vpcs.assertions.must_deny : rule.from.network_cidr if !contains([for vpc in var.generate_routes_to_other_vpcs.vpcs : vpc.network_cidr], rule.from.network_cidr)],
        [for rule in var.generate_routes_to_other_vpcs.assertions.must_deny : rule.to.network_cidr if !contains([for vpc in var.generate_routes_to_other_vpcs.vpcs : vpc.network_cidr], rule.to.network_cidr)],
        [for rule in var.generate_routes_to_other_vpcs.assertions.must_permit : rule.from.network_cidr if !contains([for vpc in var.generate_routes_to_other_vpcs.vpcs : vpc.network_cidr], rule.from.network_cidr)],
        [for rule in var.generate_routes_to_other_vpcs.assertions.must_permit : rule.to.network_cidr if !contains([for vpc in var.generate_routes_to_other_vpcs.vpcs : vpc.network_cidr], rule.to.network_cidr)],
    )))) : "n/a"
  }
}
