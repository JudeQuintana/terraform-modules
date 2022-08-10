variable "amazon_side_asn" {
  description = "required local amazon side asn"
  type        = number
}

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

variable "vpcs" {
  description = "map of tiered_vpc_ng objects"
  type = map(object({
    account_id                   = string
    region                       = string
    id                           = string
    full_name                    = string
    network                      = string
    az_to_private_route_table_id = map(string)
    az_to_private_subnet_ids     = map(list(string))
    az_to_public_route_table_id  = map(string)
    az_to_public_subnet_ids      = map(list(string))
  }))
  default = {}

  validation {
    condition     = length(distinct([for this in var.vpcs : this.network])) == length([for this in var.vpcs : this.network])
    error_message = "All VPCs must have unique network CIDRs."
  }
}
