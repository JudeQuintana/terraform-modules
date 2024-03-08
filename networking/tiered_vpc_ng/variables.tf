variable "env_prefix" {
  description = "prod, stage, test"
  type        = string
}

variable "region_az_labels" {
  description = "Region and AZ names mapped to short naming conventions for labeling"
  type        = map(string)
}

variable "tiered_vpc" {
  description = "Tiered VPC configuration"
  type = object({
    name              = string
    network_cidr      = string
    ipv6_network_cidr = optional(string)
    enable_eigw       = optional(bool, false)
    tenancy           = optional(string, "default")
    azs = map(object({
      enable_natgw = optional(bool, false)
      private_subnets = optional(list(object({
        name      = string
        cidr      = string
        ipv6_cidr = optional(string)
      })), [])
      public_subnets = list(object({
        name      = string
        cidr      = string
        ipv6_cidr = optional(string)
        special   = optional(bool, false)
      }))
    }))
  })

  validation {
    condition     = alltrue([for this in keys(var.tiered_vpc.azs) : contains(["a", "b", "c", "d", "e", "f"], this)])
    error_message = "The AZ key should be a single character for the AZ. a,b,c,d,e or f."
  }

  validation {
    condition     = alltrue([for this in var.tiered_vpc.azs : length([for subnet in this.public_subnets : subnet.special if subnet.special]) == 1])
    error_message = "There must be 1 public subnet with a special attribute set to true per AZ in a Tiered VPC."
  }

  validation {
    condition = length(distinct(flatten([
      for this in var.tiered_vpc.azs : concat(this.private_subnets[*].name, this.public_subnets[*].name)
      ]))) == length(flatten([
      for this in var.tiered_vpc.azs : concat(this.private_subnets[*].name, this.public_subnets[*].name)
    ]))
    error_message = "Each subnet name must be unique across all AZs in a Tiered VPC."
  }

  validation {
    condition = length(distinct(flatten([
      for this in var.tiered_vpc.azs : concat(this.private_subnets[*].cidr, this.public_subnets[*].cidr)
      ]))) == length(flatten([
      for this in var.tiered_vpc.azs : concat(this.private_subnets[*].cidr, this.public_subnets[*].cidr)
    ]))
    error_message = "Each subnet CDIR must be unique across all AZs in a Tiered VPC."
  }
}

variable "tags" {
  description = "Additional Tags"
  type        = map(string)
  default     = {}
}
