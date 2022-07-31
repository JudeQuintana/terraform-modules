variable "vpcs" {
  description = "map of tiered_vpc_ng objects"
  type = map(object({
    network                      = string
    az_to_private_route_table_id = map(string)
    az_to_public_route_table_id  = map(string)
  }))

  # im using a manual CIDR notation check here because there are no vpc resources in use to validate the CIDR for me.
  validation {
    condition = length([
      for vpc_name, this in var.vpcs : true
      if can(regex("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/(3[0-2]|[1-2][0-9]|[0-9]))$", this.network))
    ]) == length(var.vpcs)
    error_message = "Tiered VPC network must be in valid CIDR notation ie 10.46.0.0/20, x.x.x.x/xx ."
  }
}
