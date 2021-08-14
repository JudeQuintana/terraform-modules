variable "amazon_side_asn" {
  type    = number
  default = null
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
    id                           = string
    network                      = string
    az_to_private_route_table_id = map(string)
    az_to_private_subnet_ids     = map(list(string))
    az_to_public_route_table_id  = map(string)
    az_to_public_subnet_ids      = map(list(string))
  }))

  validation {
    condition     = length(var.vpcs) > 1
    error_message = "There must be at least 2 VPCs."
  }
}