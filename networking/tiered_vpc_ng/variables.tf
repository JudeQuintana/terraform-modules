variable "env_prefix" {
  description = "prod, stage, test"
  type        = string
}

variable "region_az_labels" {
  description = "Region and AZ names mapped to short naming conventions for labeling"
  type        = map(string)
}

variable "tiered_vpc" {
  type = object({
    name    = string
    network = string
    tenancy = optional(string, "default")
    azs = map(object({
      enable_natgw = optional(bool, false)
      private_subnets = optional(list(object({
        name = string
        cidr = string
      })), [])
      public_subnets = optional(list(object({
        name = string
        cidr = string
      })), [])
    }))
  })
  #
  # This is an example of validating CIDR notation
  # I don't think its really needed because the provider
  # will provide subnet errors if there is invalid cidrs
  # the aws provider will error on validate cidr subnets too.
  # https://blog.markhatton.co.uk/2011/03/15/regular-expressions-for-ip-addresses-cidr-ranges-and-hostnames/
  validation {
    condition     = can(regex("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/(3[0-2]|[1-2][0-9]|[0-9]))$", var.tiered_vpc.network))
    error_message = "Tiered VPC network must be in valid CIDR notation (ie x.x.x.x/xx -> 10.46.0.0/20)."
  }

  validation {
    condition = length([
      for this in var.tiered_vpc.azs : true
      if length(this.public_subnets) > 0
    ]) == length(var.tiered_vpc.azs)
    error_message = "There must be at least 1 or more public subnets per AZ."
  }

  validation {
    condition = length(distinct(flatten([
      for this in var.tiered_vpc.azs : this.private_subnets[*].name
    ]))) == length(flatten([for this in var.tiered_vpc.azs : this.private_subnets[*].name]))
    error_message = "Each private subnet name must be unique in the private subnet list."
  }

  validation {
    condition = length(distinct(flatten([
      for this in var.tiered_vpc.azs : this.private_subnets[*].cidr
    ]))) == length(flatten([for this in var.tiered_vpc.azs : this.private_subnets[*].cidr]))
    error_message = "Each private subnet CDIR must be unique in the private subnet list."
  }

  validation {
    condition = length(distinct(flatten([
      for this in var.tiered_vpc.azs : this.public_subnets[*].name
    ]))) == length(flatten([for this in var.tiered_vpc.azs : this.public_subnets[*].name]))
    error_message = "Each public subnet name must be unique in the public subnet list."
  }

  validation {
    condition = length(distinct(flatten([
      for this in var.tiered_vpc.azs : this.public_subnets[*].cidr
    ]))) == length(flatten([for this in var.tiered_vpc.azs : this.public_subnets[*].cidr]))
    error_message = "Each public subnet CDIR must be unique in the public subnet list."
  }

}

variable "tags" {
  description = "Additional Tags"
  type        = map(string)
  default     = {}
}
