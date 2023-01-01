#variable "amazon_side_asn" {
#description = "required local amazon side asn"
#type        = number
#}

#variable "blackhole_subnets" {
#description = "subnets to blackhole."
#type        = list(string)
#default     = []
#}

#variable "name" {
#description = "centralized router name"
#type        = string
#}

variable "env_prefix" {
  description = "prod, stage, test"
  type        = string
}

variable "region_az_labels" {
  description = "Region and AZ names mapped to short naming conventions for labeling"
  type        = map(string)
}

variable "tags" {
  description = "Additional Tags"
  type        = map(string)
  default     = {}
}

#variable "vpcs" {
#description = "map of tiered_vpc_ng objects"
#type = map(object({
#account_id                   = string
#az_to_private_route_table_id = map(string)
#az_to_private_subnet_ids     = map(list(string))
#az_to_public_route_table_id  = map(string)
#az_to_public_subnet_ids      = map(list(string))
#region                       = string
#id                           = string
#full_name                    = string
#network                      = string
#}))
#default = {}

#validation {
#condition     = length(distinct([for this in var.vpcs : this.network])) == length([for this in var.vpcs : this.network])
#error_message = "All VPCs must have unique network CIDRs."
#}
#}


variable "centralized_router" {
  description = "centralized router configuration"
  type = object({
    amazon_side_asn   = number
    name              = string
    blackhole_subnets = optional(list(string), [])
    vpcs = optional(map(object({
      account_id                   = string
      az_to_private_route_table_id = map(string)
      az_to_private_subnet_ids     = map(list(string))
      az_to_public_route_table_id  = map(string)
      az_to_public_subnet_ids      = map(list(string))
      region                       = string
      id                           = string
      full_name                    = string
      network                      = string
    })), {})
  })

  validation {
    condition     = length(distinct([for this in var.centralized_router.vpcs : this.network])) == length([for this in var.centralized_router.vpcs : this.network])
    error_message = "All VPCs must have unique network CIDRs."
  }
}
