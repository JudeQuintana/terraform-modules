variable "vpc_cidr_block" {
  type = string
}

variable "tiers" {
  type = list(object({
    name   = string
    acl    = string
    newbit = number
  }))
}

variable "az_newbits" {
  type = map(number)
}

