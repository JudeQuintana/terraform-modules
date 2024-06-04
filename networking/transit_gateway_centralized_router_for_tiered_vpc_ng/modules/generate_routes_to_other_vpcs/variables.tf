variable "vpcs" {
  description = "map of tiered_vpc_ng objects"
  type = map(object({
    network_cidr            = string
    secondary_network_cidrs = optional(list(string), [])
    ipv6_network_cidr       = optional(string)
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
        for secondary_network_cidr in this.secondary_network_cidrs :
        can(cidrnetmask(secondary_network_cidr))
      ]
    ]))
    error_message = "Each Secondary VPC network CIDR valid IPv4 CIDR notation (ie x.x.x.x/xx -> 10.46.0.0/20). Check for typos."
  }
}
