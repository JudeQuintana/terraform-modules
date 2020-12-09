variable "base_cidr_block" {
  type = string
}

variable "tiers" {
  type = set(object({
    name   = string
    acl    = string
    newbit = number
  }))
}

variable "az_newbits" {
  type = map(number)
}

