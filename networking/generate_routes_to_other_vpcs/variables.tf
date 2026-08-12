variable "routing_policy" {
  description = "routing policy constraints"
  type = object({
    default = optional(string, "allow")
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
  default = {}

  validation {
    condition     = contains(["allow", "deny"], var.routing_policy.default)
    error_message = "Policy default must be \"allow\" or \"deny\"."
  }

  validation {
    condition = length(
      distinct(flatten([for vpcs in var.routing_policy.segments : [for vpc in vpcs : vpc.network_cidr]]))
    ) == length(flatten([for vpcs in var.routing_policy.segments : [for vpc in vpcs : vpc.network_cidr]]))
    error_message = "A VPC cannot belong to multiple segments. Each VPC (network_cidr) must appear in only one segment or use allow = [] to create explicit allows across segments."
  }
}

variable "vpcs" {
  description = "map of tiered_vpc_ng objects"
  type = map(object({
    network_cidr            = string
    secondary_cidrs         = optional(list(string), [])
    ipv6_network_cidr       = optional(string)
    ipv6_secondary_cidrs    = optional(list(string), [])
    private_route_table_ids = list(string)
    public_route_table_ids  = list(string)
  }))

  # im using a manual CIDR notation check here because there are no vpc resources in use to validate the CIDR for me.
  validation {
    condition     = alltrue([for this in var.vpcs : can(cidrnetmask(this.network_cidr))])
    error_message = "The VPC network_cidr must be in valid IPv4 CIDR notation ie 10.46.0.0/20, x.x.x.x/xx . Check for typos."
  }

  validation {
    condition = alltrue(flatten([
      for this in var.vpcs : [
        for secondary_cidr in this.secondary_cidrs :
        can(cidrnetmask(secondary_cidr))
    ]]))
    error_message = "Each Secondary VPC CIDR valid IPv4 CIDR notation (ie x.x.x.x/xx -> 10.46.0.0/20). Check for typos."
  }
}

