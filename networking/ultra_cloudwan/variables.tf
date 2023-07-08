
variable "region_az_labels" {
  description = "Region and AZ names mapped to short naming conventions for labeling"
  type        = map(string)
}

variable "tags" {
  description = "Additional Tags"
  type        = map(string)
  default     = {}
}

variable "ultra_cloudwan" {
  description = "ultra cloudwan configuration."

  type = object({
    name = string
    super_routers = list(object({
      local = object({
        account_id      = string
        amazon_side_asn = string
        full_name       = string
        id              = string
        network_cidrs   = string
        region          = string
        route_table_id  = string
      })
      peer = object({
        account_id      = string
        amazon_side_asn = string
        full_name       = string
        id              = string
        network_cidrs   = string
        region          = string
        route_table_id  = string
      })
    }))
  })
}
