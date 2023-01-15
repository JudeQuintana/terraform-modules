locals {
  provider_to_vpc_region_check = {
    condition     = alltrue([for this in var.vpcs : contains([local.region_name], this.region)])
    error_message = "All Tiered VPC regions must match the aws provider region for Centralized Router."
  }
}
