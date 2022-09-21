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

variable "tier" {
  type = object({
    azs = map(object({
      enable_natgw = optional(bool, false)
      private      = list(string)
      public       = list(string)
    }))
    name    = string
    network = string
    tenancy = optional(string, "default")
  })

  # Requiring at least one public subnet allows for
  # making it easy for `enable_natgw = true` so we
  # can build everything needed for adding a natgw automatically
  # ie EIP, update route tables, associate public subnet
  # it also makes it easy to select and attach AZs to the
  # TGW Centralized router since it has to be one subnet
  # either public or private
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
  # the aws provider will error on validate cidr subnets too.
  # https://blog.markhatton.co.uk/2011/03/15/regular-expressions-for-ip-addresses-cidr-ranges-and-hostnames/
  validation {
    condition     = can(regex("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/(3[0-2]|[1-2][0-9]|[0-9]))$", var.tier.network))
    error_message = "Tier network must be in valid cidr notation ie 10.46.0.0/20, x.x.x.x/xx ."
  }
}
