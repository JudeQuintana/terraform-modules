variable "base_cidr_block" {
  description = "Large starting CIDR block ie 10.0.0.0/16"
  type        = string
}

variable "tiers" {
  description = "Networking tiers"
  type = list(object({
    name   = string
    acl    = string
    newbit = number
  }))
}

variable "az_newbits" {
  description = "New bits to add to calculated cidr blocks for subnets per AZ"
  type        = map(number)
}

