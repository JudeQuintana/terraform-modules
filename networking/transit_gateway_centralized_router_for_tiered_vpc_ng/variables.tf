variable "env_prefix" {
  description = "prod, stage, test"
  type        = string
}

variable "region_az_labels" {
  description = "Region and AZ names mapped to short naming conventions for labeling"
  type        = map(string)
}

variable "centralized_router" {
  description = "centralized router configuration"
  type = object({
    amazon_side_asn        = number
    name                   = string
    blackhole_subnet_cidrs = optional(list(string), [])
    vpcs = optional(map(object({
      account_id                   = string
      az_to_private_route_table_id = map(string)
      az_to_private_subnet_ids     = map(list(string))
      az_to_public_route_table_id  = map(string)
      az_to_public_subnet_ids      = map(list(string))
      full_name                    = string
      id                           = string
      name                         = string
      network_cidr                 = string
      region                       = string
    })), {})
  })

  validation {
    condition     = length(distinct([for this in var.centralized_router.vpcs : this.name])) == length([for this in var.centralized_router.vpcs : this.name])
    error_message = "All VPCs must have unique names."
  }

  validation {
    condition     = length(distinct([for this in var.centralized_router.vpcs : this.network_cidr])) == length([for this in var.centralized_router.vpcs : this.network_cidr])
    error_message = "All VPCs must have unique network CIDRs."
  }
}

variable "tags" {
  description = "Additional Tags"
  type        = map(string)
  default     = {}
}

