variable "env_prefix" {
  description = "prod, stage, etc"
  type        = string
}

variable "region_az_labels" {
  description = "Region and AZ names mapped to short naming conventions for labeling"
  type        = map(string)
}

variable "vpc_tenancy" {
  description = "Set VPC Tenancy"
  type        = string
  default     = "default"
}

variable "tags" {
  description = "Additional Tags"
  type        = map(string)
  default     = {}
}

variable "tier" {
  type = object({
    name    = string
    network = string
    azs = map(object({
      public  = list(string)
      private = list(string)
    }))
  })

  validation {
    condition = length([
      for az in var.tier.azs : true
      if length(az.public) > 0
    ]) == length(var.tier.azs)
    error_message = "There must be at least 1 public subnet per az."
  }

  # This is an example of validating CIDR notation
  # I don't think its really needed because the provider
  # will provide subnet errors if there is invalid cidrs
  validation {
    # https://blog.markhatton.co.uk/2011/03/15/regular-expressions-for-ip-addresses-cidr-ranges-and-hostnames/
    # the aws provider will error on validate cidr subnets too.
    condition     = can(regex("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/(3[0-2]|[1-2][0-9]|[0-9]))$", var.tier.network))
    error_message = "Tier network must be in valid cidr notation ie 10.46.0.0/20, x.x.x.x/xx ."
  }
}
